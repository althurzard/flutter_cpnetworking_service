import 'model/auth_session_info.dart';

typedef ItemCreator<S> = S Function();

typedef ItemsCreator<L> = List<L> Function();

abstract class BaseModelInterface extends JSONable {}

abstract class PagingInterface extends JSONable {
  late int pageNumber;
  late int pageSize;
}

class ResponseListData<T extends BaseModelInterface> {
  ItemsCreator creators;
  PagingInterface? paging;
  ResponseListData(this.creators, {this.paging});
  List<T> get data {
    return creators() as List<T>;
  }
}
