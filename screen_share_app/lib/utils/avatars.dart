/// Avatares disponíveis para os participantes.
///
/// Para adicionar mais, é só colocar o PNG em `assets/images/avatars/` e
/// incluir o caminho nesta lista (a pasta inteira já está registrada no
/// pubspec.yaml).
const List<String> avatarAssets = [
  'assets/images/avatars/gato_1.png',
];

/// Escolhe um avatar a partir do nome. O mesmo nome sempre resulta no mesmo
/// avatar, em qualquer computador, sem precisar combinar nada pelo servidor.
String avatarFor(String name) {
  var hash = 0;
  for (final unit in name.trim().toLowerCase().codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return avatarAssets[hash % avatarAssets.length];
}
