// Request urls
const String baseUrl = 'https://api.github.com';
const String githubUrl = 'https://github.com';
const String trendingUrl = 'https://gtrend.yapie.me';

const String clientId = '2e8c824a38d3ddfe1c59';
const String clientSecret = 'b1d1ad48f6c6dddbf11e10f616a951c705a546a4';
const String githubAuthUrl = "https://github.com/login/oauth/authorize"
    "?client_id=$clientId"
    "&state=$clientSecret"
    "&redirect_uri=jithub://oauth.login"
    "&scope=repo%20gist%20notifications%20user%20"; // repo gits notifications user
const String githubRedirectUrl = "jithub://oauth.login";


// Rest APIs
const String apiAccessToken = '/login/oauth/access_token';


const int perPageSize = 30;
