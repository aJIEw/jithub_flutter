class TrendingRepoLanguageColors {
  static const String defaultColor = '#000000';

  static const Map<String, String> _colors = {
    'dart': '#00B4AB',
    'flutter': '#02569B',
    'javascript': '#F1E05A',
    'typescript': '#3178C6',
    'python': '#3572A5',
    'java': '#B07219',
    'kotlin': '#A97BFF',
    'swift': '#F05138',
    'objective-c': '#438EFF',
    'c': '#555555',
    'c++': '#F34B7D',
    'c#': '#178600',
    'go': '#00ADD8',
    'rust': '#DEA584',
    'ruby': '#701516',
    'php': '#4F5D95',
    'scala': '#C22D40',
    'shell': '#89E051',
    'bash': '#89E051',
    'html': '#E34C26',
    'css': '#563D7C',
    'scss': '#C6538C',
    'vue': '#41B883',
    'svelte': '#FF3E00',
    'jupyter notebook': '#DA5B0B',
    'lua': '#000080',
    'perl': '#0298C3',
    'r': '#198CE7',
    'elixir': '#6E4A7E',
    'erlang': '#B83998',
    'haskell': '#5E5086',
    'clojure': '#DB5855',
    'groovy': '#4298B8',
    'powershell': '#012456',
    'dockerfile': '#384D54',
    'makefile': '#427819',
  };

  static const Map<String, String> _aliases = {
    'ts': 'typescript',
    'js': 'javascript',
    'golang': 'go',
    'py': 'python',
    'csharp': 'c#',
    'cplusplus': 'c++',
    'objective c': 'objective-c',
    'objectivec': 'objective-c',
    'sh': 'shell',
  };

  static String resolve(String? language) {
    if (language == null) return defaultColor;

    final normalized = language.trim().toLowerCase();
    if (normalized.isEmpty) return defaultColor;

    final aliased = _aliases[normalized] ?? normalized;
    return _colors[aliased] ?? defaultColor;
  }
}
