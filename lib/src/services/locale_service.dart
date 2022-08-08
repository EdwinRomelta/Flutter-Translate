import 'dart:convert';
import 'dart:ui';
import 'package:flutter_translate/flutter_translate.dart';

import 'locale_file_service.dart';

class LocaleService
{
    static Future<Map<Locale, List<String>>> getLocalesMap(List<String> locales, String basePath, List<String>? packagesPath) async
    {
        var files = await LocaleFileService.getLocaleFiles(locales, basePath);
        final fileMap = files.map((x,y) => MapEntry(localeFromString(x), [y]));
        if(packagesPath != null) {
            for (final packagePath in packagesPath) {
                var packageFiles = await LocaleFileService.getLocaleFiles(
                    locales, packagePath);
                for (final file in packageFiles.entries) {
                    fileMap[localeFromString(file.key)]?.add(file.value);
                }
            }
        }
        return fileMap;
    }

    static Locale? findLocale(Locale locale, List<Locale> supportedLocales)
    {
        // Not supported by all null safety versions
        Locale? existing; // = supportedLocales.firstWhereOrNull((x) => x == locale);

        for (var x in supportedLocales) 
        {
            if (x == locale) 
            {
                existing = x;
                break;
            }
        }

        if(existing == null)
        {
            // Not supported by all null safety versions
            // existing = supportedLocales.firstWhereOrNull((x) => x.languageCode == locale.languageCode);
            for (var x in supportedLocales) 
            {
                if (x.languageCode == locale.languageCode) 
                {
                    existing = x;
                    break;
                }
            }

        }

        return existing;
    }

    static Future<Map<String, dynamic>> getLocaleContent(Locale locale, Map<Locale, List<String>> supportedLocales) async
    {
        var files = supportedLocales[locale];

        if (files == null) return {};
        final localizationMap = <String, dynamic>{};
        for(final file in files) {
            var content = await LocaleFileService.getLocaleContent(file);
            var map = content != null ? json.decode(content) : {};
            if(file.startsWith('packages/')){
                map = {file.split('/')[1] : map};
            }
            localizationMap.addAll(map);
        }

        return localizationMap;
    }


}
