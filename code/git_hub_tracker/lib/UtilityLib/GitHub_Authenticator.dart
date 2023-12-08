import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:git_hub_tracker/UtilityLib/CredentialStorage.dart';
import 'package:git_hub_tracker/UtilityLib/SecretConsts.dart';
import 'package:oauth2/oauth2.dart';
import 'package:dio/dio.dart';
import 'package:git_hub_tracker/UtilityLib/StringToBase64.dart';
import 'package:http/http.dart' as http;

//New HttpClient to get json format response
class GitHubOAuthHttpClient extends http.BaseClient {
  final httpClient = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Accept'] = 'application/json';
    httpClient.send(request);
  }
}



class GitHubAuthenticator {
  late final CredentialStorage _credentialStorage;
  late final Dio _dio;

  GitHubAuthenticator(this._credentialStorage, this._dio);

  Future<Credentials?> getSignedInCredentials() async {
    try
    {
      final storedCredentials = await _credentialStorage.read();
      if(storedCredentials != null)
      {
        if(storedCredentials.canRefresh && storedCredentials.isExpired)
        {
          //todo: Refresh the token
        }
      }
      return storedCredentials;
    }
    on PlatformException{
      return null;
    }
  }

  Future<bool> isSignedIn() => getSignedInCredentials().then((credentials) => credentials != null);

  AuthorizationCodeGrant createGrant() {
    return AuthorizationCodeGrant(
      SecretConsts.clientId,
      SecretConsts.authEndPoint,
      SecretConsts.tokenEndPoint,
      secret: SecretConsts.clientSecret,
      httpClient: GitHubOAuthHttpClient(),
    );
  }
  
  Uri getAuthorizationUrl(AuthorizationCodeGrant grant) {
    return grant.getAuthorizationUrl(
      SecretConsts.redirectUrl,
      scopes: SecretConsts.scopes
    );
  }

  Future<void> handleAuthorizationResponse( AuthorizationCodeGrant grant, Map<String, String> queryParams) async {
    final httpClient = await grant.handleAuthorizationResponse(queryParams);
    await _credentialStorage.save(httpClient.credentials);
  }

  Future<void> signIn() async {

  }

  Future<void> signOut() async {
    final accessToken = await _credentialStorage.read().then((credentials) => credentials?.accessToken);
    final userPass = stringToBase64.encode('${SecretConsts.clientId}:${SecretConsts.clientSecret}');

    _dio.deleteUri(
      SecretConsts.revocationEndpoint,
      data: {
        'access_token': accessToken,
      },
      options: Options(
        headers: {
          'Authorization':'basic $userPass',
        }
      ),
    );

    await _credentialStorage.clear();
  }

}