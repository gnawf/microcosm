/// The normal [List.last] is actually [Iterable.last] which uses an iterator
/// to get the last element. So [List.last] is O(N). Just crazy.
extension NotDumbFuckOpereations<T> on List<T> {
  T tail() {
    return isNotEmpty ? this[length - 1] : null;
  }
}
