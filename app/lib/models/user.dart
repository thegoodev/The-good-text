class GoodUser {
  String uid, photoUrl, displayName, description;

  GoodUser({
    required this.uid,
    required this.photoUrl,
    required this.displayName,
    required this.description,
  });

  String get firstName => displayName.split(" ")[0];
}
