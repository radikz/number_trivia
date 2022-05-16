import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<ConnectivityResult> get connectivityResult;
}

class NetworkInfoImpl implements NetworkInfo {

  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<ConnectivityResult> get connectivityResult => connectivity.checkConnectivity();

}