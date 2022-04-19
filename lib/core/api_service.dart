class ApiService {
  static const int perPageSize = 30;

  // Request urls
  static const String baseUrl = 'https://api.github.com';
  static const String githubUrl = 'https://github.com';
  static const String trendingUrl = 'https://gtrend.yapie.me';

  static const String clientId = '2e8c824a38d3ddfe1c59';
  static const String clientSecret = 'b1d1ad48f6c6dddbf11e10f616a951c705a546a4';
  static const String githubAuthUrl = "https://github.com/login/oauth/authorize"
      "?client_id=$clientId"
      "&state=$clientSecret"
      "&redirect_uri=jithub://oauth.login"
      "&scope=repo%20gist%20notifications%20user%20"; // repo gits notifications user
  static const String githubRedirectUrl = "jithub://oauth.login";

  // Rest APIs
  static const String apiAccessToken = '/login/oauth/access_token';
  static const String apiTrendingRepos = '/repositories';
  static const String apiReceivedEvents = '/users/%s/received_events';
  static const String apiUserInfo = '/users/%s';
  static const String apiUserEvents = '/users/%s/events';
}
