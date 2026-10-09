import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/popup.dart';
import '../data/providers/remote_providers.dart';
import '../data/remote/repositories.dart';
import 'popup_card.dart';

/// Wraps the app and shows the highest-priority launch popup once per cold
/// start, after the first frame so it never races the router.
///
/// Placement popups (home, course) are requested by those screens instead.
class PopupHost extends ConsumerStatefulWidget {
  const PopupHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PopupHost> createState() => _PopupHostState();
}

class _PopupHostState extends ConsumerState<PopupHost> {
  bool _shown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shown) return;

    final popups = ref.read(popupsProvider(PopupPlacement.appLaunch));
    popups.whenData((list) {
      if (list.isEmpty || _shown) return;
      _shown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _present(list.first));
    });
  }

  Future<void> _present(AppPopup popup) async {
    if (!mounted) return;

    final target = await showAppPopup(
      context,
      popup,
      onShown: () => Repo.recordPopupView(popup.id),
      onClicked: () => Repo.recordPopupClick(popup.id),
      onDismissed: () => Repo.dismissPopup(popup.id),
    );

    if (target == null || !mounted) return;

    // Only in-app routes are followed; an external URL would need
    // url_launcher and an explicit confirmation.
    if (target.startsWith('/')) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushNamed(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep the provider alive so didChangeDependencies sees it resolve.
    ref.watch(popupsProvider(PopupPlacement.appLaunch));
    return widget.child;
  }
}
