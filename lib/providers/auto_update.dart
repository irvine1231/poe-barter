import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:github/github.dart';
import 'package:package_info_plus_windows/package_info_plus_windows.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateProvider extends ChangeNotifier {
  bool isDownloading = false;
  final GitHub github = GitHub();
  final RepositorySlug repositorySlug = RepositorySlug("irvine1231", "poe-barter");
  bool newVersionDownloaded = false;

  UpdateProvider() {
    updateHandler();
  }

  Future<bool?> retrieveNewVersionDownloadedInPreference() async {
    final prefs = await SharedPreferences.getInstance();

    final bool? newVersionDownloadedPref = prefs.getBool("newVersionDownloaded");
    newVersionDownloaded = newVersionDownloadedPref ?? false;

    return newVersionDownloadedPref;
  }

  Future<void> setNewVersionDownloadedInPreference(bool newVersionDownloaded) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setBool("newVersionDownloaded", newVersionDownloaded);
  }

  Future<String?> retrieveNewVersionFilePathInPreference() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("newVersionFilePath");
  }

  Future<void> setNewVersionFilePathInPreference(String newVersionFilePath) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString("newVersionFilePath", newVersionFilePath);
  }

  Future<String?> retrieveNewVersionNameInPreference() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("newVersionName");
  }

  Future<void> setNewVersionNameInPreference(String newVersionName) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString("newVersionName", newVersionName);
  }

  Future<void> resetNewVersionPrefs() async {
    await setNewVersionNameInPreference("");
    await setNewVersionFilePathInPreference("");
    await setNewVersionDownloadedInPreference(false);
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
    final packageInfo = await PackageInfoWindows().getAll();
    final currentVersion = packageInfo.version;

    if (((await retrieveNewVersionNameInPreference()) ?? "") == "v$currentVersion") {
      await resetNewVersionPrefs();
    }

    if ((await retrieveNewVersionDownloadedInPreference()) ?? false) return;

    final Release? githubRelease = await fetchLatestReleaseFromGithub();

    final ReleaseAsset? firstAsset = githubRelease?.assets?.first;
    if (githubRelease != null && githubRelease.tagName != "v$currentVersion" && firstAsset != null) {
      final String? newVersionFilePath = await downloadLatestReleaseAsset(firstAsset);

      if (newVersionFilePath != null) {
        await setNewVersionNameInPreference(githubRelease.tagName!);
        await setNewVersionFilePathInPreference(newVersionFilePath);
        await setNewVersionDownloadedInPreference(true);
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
