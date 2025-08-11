String generateSlug(String title) {
  return title
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s-]'), '') // Remove invalid chars
      .replaceAll(RegExp(r'\s+'), '-') // Replace spaces with hyphens
      .replaceAll(RegExp(r'-+'), '-'); // Replace multiple hyphens with single
}