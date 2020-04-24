import 'package:http_interceptor/http_interceptor.dart';
import 'package:tasks/services/auth_service.dart';

class HttpInterceptor implements InterceptorContract {
  AuthService authService;

  HttpInterceptor() {
    authService = new AuthService();
  }

  @override
  Future<RequestData> interceptRequest({RequestData data}) async {
    authService.handleTokenRefresh();
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({ResponseData data}) async {
    return data;
  }
}
