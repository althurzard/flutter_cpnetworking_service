# flutter_cpnetworking_service

A netowrking wrapper which using dio and flutter_secure_storage(ios, android)/shared_preferences(web) to handle storage token or sensitive data in general, and use token as authorization info when requesting to http connection.

## Usage

We’re going to use random news API which generates news data and returns it in JSON format.

Basic news model
```dart
class NewsEnity implements BaseModelInterface {
  final String title;
  final String id;
  final String description;
  final List<String> categories;
  final List<String> medias;
  final int published;
  String formattedPublished(String languageCode) {
    var date = DateTime.fromMillisecondsSinceEpoch(published);
    var formattedDate = DateFormat.yMMMMd(languageCode).format(date);
    return formattedDate;
  }
  NewsEnity(
      {@required this.title,
      @required this.id,
      @required this.description,
      @required this.medias,
      @required this.categories,
      @required this.published});
  factory NewsEnity.fromJson(Map<String, dynamic> json) {
    List<String> category;
    if (json['category'] is String) {
      category = [json['category'].toString()];
    }
    return NewsEnity(
        title: json['title'],
        id: json['id'],
        description: json['description'],
        categories: category ??
            (json['category'] as List).map((e) => e.toString()).toList() ??
            [],
        medias:
            (json['medias'] as List).map((e) => e.toString()).toList() ?? [],
        published: json['published']);
  }
  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
```

## Repository

The repository abstract class will mediate between high level components of our architecture(Bloc and Client API Provider)
```dart
abstract class NewsRepository {
  Future<ResponseListData<NewsEnity>> fetchHotNews();
  Future<ResponseListData<NewsEnity>> fetchLocalNews();
}

enum _Path { Hot, Local }
class _URLPathHelper {
  static String value(_Path value) {
    switch (value) {
      case _Path.Hot:
        return '/application/news/hot';
      case _Path.Local:
        return '/application/news/local';
      default:
        return '';
    }
  }
}

class NewsClient extends APIProvider implements NewsRepository {
  @override
  Future<ResponseListData<NewsEnity>> fetchHotNews() async {
    var input = DefaultInputService(path: _URLPathHelper.value(_Path.Local));
    final response = await super.request(input: input);
    var result = (response.data['data'] as List)
        .map((e) => NewsEnity.fromJson(e))
        .toList();
    return ResponseListData<NewsEnity>(() => result);
  }
  @override
  Future<ResponseListData<NewsEnity>> fetchLocalNews() {
    return Future.error(AppError(message: ''));
  }
  NewsClient(
      {@required StorageTokenProcessor storageTokenProcessor,
      @required NetworkConfigurable networkConfigurable,
      Interceptor interceptor})
      : super(
            storageTokenProcessor: storageTokenProcessor,
            networkConfiguration: networkConfigurable,
            interceptor: interceptor);
}
```
## Bloc

Let’s add high level component of our architecture which is bloc (business logic component — read about it [here](https://medium.com/flutterpub/architecting-your-flutter-project-bd04e144a8f1)).

NewsBlocis the only component which can be used from UI class (in terms of clean architecture). NewsBlocfetches data from repository and notify it via states.
```dart
class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsRepository newsRepository;
  final StorageTokenProcessor storageTokenProcessor;
  NewsBloc(
      {@required this.newsRepository, @required this.storageTokenProcessor})
      : super(NewsInitial());
  @override
  Stream<NewsState> mapEventToState(NewsEvent event) async* {
    if (event is FetchNews) {
      yield NewsLoading();
      yield* _fetchNews(event);
    }
  }
  Stream<NewsState> _fetchNews(FetchNews params) async* {
    try {
      var localNews = await newsRepository.fetchHotNews();
      yield NewsLoaded(hotNews: [], localNews: localNews.data);
    } on AppError catch (e, stack) {
      yield NewsError(message: e.message);
    }
  }
}

@immutable
abstract class NewsEvent {}

class FetchNews extends NewsEvent {}

@immutable
abstract class NewsState {}

class NewsLoaded extends NewsState {
  final List<NewsEnity> hotNews;
  final List<NewsEnity> localNews;
  NewsLoaded({
    @required this.hotNews,
    @required this.localNews,
  });
}
```