/// Like Flutter's binarySearch, but will return nearest index, prefering the lower index.
int binarySearchReturnLowest<num>(
    List<double> sortedList, double value, {bool matchReturnsMin = false}) {
  int start = 0;
  int end = sortedList.length - 1;
  int mid;
  assert(sortedList[0] < sortedList[1]);

  while (start <= end) {
    mid = ((start + end) / 2).floor();
    if (sortedList[mid] == value) {
      if (matchReturnsMin) {
        mid--;
      }
      return mid;
    } else if (sortedList[mid] < value) {
      start = mid + 1;
    } else {
      end = mid - 1;
    }
  }
  return start - 1;
}
