class ApiService {
  static const int perPageSize = 30;
  static const String clientId = '2e8c824a38d3ddfe1c59';
  static const String githubOauthScopes = 'repo gist notifications user';

  // Request urls
  static const String baseUrl = 'https://api.github.com';
  static const String githubUrl = 'https://github.com';
  static const String trendingUrl = 'https://trend.doforce.dpdns.org';

  // Rest APIs
  static const String apiAccessToken = '/login/oauth/access_token';
  static const String apiDeviceCode = '/login/device/code';
  static const String apiGraphql = '/graphql';
  static const String apiTrendingRepos = '/repo';
  static const String apiReceivedEvents = '/users/%s/received_events';
  static const String apiUserInfo = '/users/%s';
  static const String apiUserEvents = '/users/%s/events';
  static const String apiUserRepos = '/user/repos';
  static const String apiStarredRepos = '/users/%s/starred';
  static const String apiStarRepo = '/user/starred/%s/%s';
}
