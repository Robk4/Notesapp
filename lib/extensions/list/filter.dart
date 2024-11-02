//Function that allows to filter the stream list of "something" if that "something" passes the test it will be
//included in the test.
extension Filter<T> on Stream<List<T>> {
  Stream<List<T>> filter(bool Function(T) where) =>
      map((items) => items.where(where).toList());
}
