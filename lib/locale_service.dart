import 'dart:convert';
import 'dart:ui';
import 'locale_file_service.dart';
import 'global.dart';

class LocaleService
{
    static Future<Map<Locale, List<String>>> getLocalesMap(List<String> locales, String basePath, List<String> packagesPath) async
    {
        var files = await LocaleFileService.getLocaleFiles(locales, basePath);
        final fileMap = files.map((x,y) => MapEntry(localeFromString(x), [y]));
        if(packagesPath != null) {
            for (final packagePath in packagesPath) {
                var packageFiles = await LocaleFileService.getLocaleFiles(
                    locales, packagePath);
                for (final file in packageFiles.entries) {
                    fileMap[localeFromString(file.key)].add(file.value);
                }
            }
        }
        return fileMap;
    }

    static Locale findLocale(Locale locale, List<Locale> supportedLocales)
    {
        var existing = supportedLocales.firstWhere((x) => x == locale, orElse: () => null);

        if(existing == null)
        {
            existing = supportedLocales.firstWhere((x) => x.languageCode == locale.languageCode, orElse: () => null);
        }

        return existing;
    }

    static Future<Map<String, dynamic>> getLocaleContent(Locale locale, Map<Locale, List<String>> supportedLocales) async
    {
        final localizationMap = <String, dynamic>{};
        var files = supportedLocales[locale];

        for(final file in files) {
            var content = await LocaleFileService.getLocaleContent(file);
            var map = json.decode(content);
            if(file.startsWith('packages/')){
                map = {file.split('/')[1] : map};
            }
            localizationMap.addAll(map);
        }

        return localizationMap;
    }


}
