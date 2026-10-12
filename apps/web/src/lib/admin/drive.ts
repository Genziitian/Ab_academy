/**
 * Pulls the file id out of anything an admin might paste for a Google Drive
 * PDF: a share link (`/file/d/<id>/view`), an `open?id=` / `uc?id=` link, or
 * the bare id. Returns null when nothing id-shaped is found.
 */
export function driveFileId(input: string): string | null {
  const value = input.trim();
  if (!value) return null;

  const patterns = [
    /\/file\/d\/([A-Za-z0-9_-]{20,})/,
    /[?&]id=([A-Za-z0-9_-]{20,})/,
    /^([A-Za-z0-9_-]{20,})$/,
  ];
  for (const pattern of patterns) {
    const match = value.match(pattern);
    if (match) return match[1];
  }
  return null;
}
