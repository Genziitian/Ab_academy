import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../config/env.dart';
import '../theme/app_colors.dart';
import 'common.dart';

/// A page of the website (About, Terms, Privacy, Contact) shown inside the
/// app. Only the academy's own site is loaded; any other link is ignored.
class WebPageScreen extends StatefulWidget {
  const WebPageScreen({super.key, required this.title, required this.path});

  final String title;

  /// Path on the website, e.g. `/privacy`.
  final String path;

  @override
  State<WebPageScreen> createState() => _WebPageScreenState();
}

class _WebPageScreenState extends State<WebPageScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final site = Uri.parse(Env.siteUrl);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onNavigationRequest: (request) =>
              Uri.tryParse(request.url)?.host == site.host
              ? NavigationDecision.navigate
              : NavigationDecision.prevent,
        ),
      )
      ..loadRequest(site.resolve(widget.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(title: widget.title),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
