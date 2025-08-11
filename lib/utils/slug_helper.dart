String generateSlug(String title) {
  return title
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(' ', '-')
      .replaceAll(RegExp(r'-+'), '-');
}