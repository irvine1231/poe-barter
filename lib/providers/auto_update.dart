import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:github/github.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:poe_barter/screens/screen_update.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateProvider extends ChangeNotifier {
  bool isDownloading = false;
  final GitHub github = GitHub();
  final RepositorySlug repositorySlug = RepositorySlug("irvine1231", "poe-barter");

  late final String newVersionFolderPath;

  bool _newVersionDownloaded = false;
  bool get newVersionDownloaded => _newVersionDownloaded;
  set newVersionDownloaded(bool value) {
    _newVersionDownloaded = value;

    notifyListeners();
  }

  UpdateProvider() {
    updateHandler();
  }

  Future<bool?> retrieveNewVersionDownloadedInPreference() async {
    final prefs = await SharedPreferences.getInstance();

    final bool? newVersionDownloadedPref = prefs.getBool("newVersionDownloaded");
    newVersionDownloaded = newVersionDownloadedPref ?? false;

    return newVersionDownloadedPref;
  }

  Future<void> setNewVersionDownloadedInPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    newVersionDownloaded = value;

    prefs.setBool("newVersionDownloaded", value);
  }

  Future<String?> retrieveNewVersionFilePathInPreference() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("newVersionFilePath");
  }

  Future<void> setNewVersionFilePathInPreference(String value) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString("newVersionFilePath", value);
  }

  Future<String?> retrieveNewVersionNameInPreference() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("newVersionName");
  }

  Future<void> setNewVersionNameInPreference(String value) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString("newVersionName", value);
  }

  void removeAllDownloadedVersionFile() {
    Directory(newVersionFolderPath).deleteSync(
      recursive: true,
    );

    Directory(newVersionFolderPath).createSync(
      recursive: true,
    );
  }

  Future<void> resetNewVersionPrefs() async {
    await setNewVersionNameInPreference("");
    await setNewVersionFilePathInPreference("");
    await setNewVersionDownloadedInPreference(false);

    removeAllDownloadedVersionFile();
  }

  Future<void> installUpdate() async {
    if ((await retrieveNewVersionDownloadedInPreference()) ?? false) {
      String? newVersionFilePath = await retrieveNewVersionFilePathInPreference();
      if (newVersionFilePath != null) {
        await Process.start(newVersionFilePath, ["-t", "-l", "1000"]).then((value) {
          exit(0);
        });
      }
    }
  }

  Future<void> updateHandler() async {
    newVersionFolderPath = "${(await getApplicationSupportDirectory()).path}\\newVersion\\";

    final packageInfo = (await PackageInfo.fromPlatform());
    final currentVersion = packageInfo.version;

    if (((await retrieveNewVersionNameInPreference()) ?? "") == "v$currentVersion") {
      await resetNewVersionPrefs();
    }

    if ((await retrieveNewVersionDownloadedInPreference()) ?? false) {
      if (newVersionDownloaded == true) {
        navService.pushReplacementNamed(ScreenUpdate.routeName);
      }

      return;
    }

    final Release? githubRelease = await fetchLatestReleaseFromGithub();

    final ReleaseAsset? foundAsset = githubRelease?.assets?.firstWhereOrNull((asset) {
      return asset.name?.endsWith('.exe') ?? false;
    });

    if (githubRelease != null && githubRelease.tagName != "v$currentVersion" && foundAsset != null) {
      final String? newVersionFilePath = await downloadLatestReleaseAsset(foundAsset);

      if (newVersionFilePath != null) {
        await setNewVersionNameInPreference(githubRelease.tagName!);
        await setNewVersionFilePathInPreference(newVersionFilePath);
        await setNewVersionDownloadedInPreference(true);

        if (newVersionDownloaded == true) {
          navService.pushReplacementNamed(ScreenUpdate.routeName);
        }
      }
    } else {
      await resetNewVersionPrefs();
    }
  }

  Future<Release?> fetchLatestReleaseFromGithub() async {
    if ((await retrieveNewVersionDownloadedInPreference()) ?? false) return null;

    return await github.repositories.getLatestRelease(
      repositorySlug,
    );
  }

  Future<String?> downloadLatestReleaseAsset(ReleaseAsset releaseAsset) async {
    if ((await retrieveNewVersionDownloadedInPreference()) ?? false) return null;
    if (isDownloading) return null;
    isDownloading = true;

    HttpClient httpClient = new HttpClient();
    final request = await httpClient.getUrl(
      Uri.parse("https://api.github.com/repos/${repositorySlug.toString()}/releases/assets/${releaseAsset.id}"),
    );
    request.headers.add("accept", "application/octet-stream");

    final response = await request.close();
    isDownloading = false;

    if (response.statusCode == 200) {
      var bytes = await consolidateHttpClientResponseBytes(response);

      final String newVersionFolderPath = "${(await getApplicationSupportDirectory()).path}\\newVersion\\";
      Directory newVersionFolder = Directory(newVersionFolderPath);
      if (!newVersionFolder.existsSync()) {
        newVersionFolder.createSync(recursive: true);
      }

      final String downloadedFilePath = "$newVersionFolderPath${releaseAsset.name}";

      final file = File(downloadedFilePath);
      await file.writeAsBytes(bytes);

      return downloadedFilePath;
    }

    return null;
  }
}
