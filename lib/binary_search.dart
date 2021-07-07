/// Like Flutter's binarySearch, but will return nearest index, prefering the lower index.
int binarySearchReturnLowest<num>(List<double> sortedList, double value) {
  int start = 0;
  int end = sortedList.length - 1;
  int mid;
  while (start <= end) {
    mid = ((start + end) / 2).floor();
    if (mid == value) {
      return mid;
    } else if (mid < value) {
      start = mid + 1;
    } else {
      end = mid - 1;
    }
  }
  return start;
}