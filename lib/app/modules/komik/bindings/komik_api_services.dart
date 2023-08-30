import 'package:appsoed/app/modules/komik/model/komik_model.dart';
import 'package:http/http.dart' as http;

class ComicAPIService {
  static const String _baseURL = 'https://api.bem-unsoed.com/api';

  Future<List<Comic>> getComics() async {
    final http.Response response = await http.get(
      Uri.parse('$_baseURL/comic'),
    );
    print(response.body);
    return comicsFromJson(response.body);
  }

  Future<Comic> getComic(dynamic id) async {
    final http.Response response = await http.get(
      Uri.parse('$_baseURL/comic/{$id}'),
    );
    return comicFromJson(response.body);
  }

  String getCoverUri(String? cover) {
    final uri = ('$_baseURL/comic/cover/$cover');
    return uri;
  }

  String getImageUri(String? image) {
    final uri = ('$_baseURL/comic/content/$image');
    return uri;
  }
}
