import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_event/keyboard_event.dart';
import 'package:poe_trading_assistant/models/command.dart';
import 'package:win32/win32.dart';

class TestProvider extends ChangeNotifier {
  static const String poeValidName = "Path of Exile";
  static const int maxPath = 260;

  static const String clientLogFolderName = "logs";
  static const String clientLogFileName = "Client.txt";
  static const String koreanClientLogFileName = "KakaoClient.txt";

  bool isPoeActive = false;

  late KeyboardEvent keyboardEvent = KeyboardEvent();

  String poeProcessName = "";
  String poePath = "";
  File? clientLogFile;
  Stream<List<int>>? clientLogFileStream;
  StreamSubscription? clientLogFileStreamSubscription;
  int clientLogLastIndex = 0;
  List<String> clientLogs = [];

  int _poeHWND = 0;
  int get poeHWND => _poeHWND;
  set poeHWND(int value) {
    _poeHWND = value;

    notifyListeners();
  }

  int _poeProcessId = 0;
  int get poeProcessId => _poeProcessId;
  set poeProcessId(int value) {
    _poeProcessId = value;

    notifyListeners();
  }

  TestProvider() {
    getPoeProcess();
  }

  void getPoeProcess() async {
    int hwnd = 0;
    String windowText = "";

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));
      hwnd = getHWND();

      windowText = getWindowText(hwnd);
      if (windowText == poeValidName) {
        isPoeActive = true;

        if (poeHWND == 0 || poeProcessId == 0) {
          poeHWND = hwnd;
          poeProcessId = getProcessId(poeHWND);
          poePath = getPoePath();

          listenForPoeClientLog();
        }
      } else {
        isPoeActive = false;
      }

      CloseHandle(hwnd);
      return true;
    });

    keyboardEvent.startListening((keyEvent) {
      if (!isPoeActive) return;

      if (keyEvent.isKeyUP) {
        if (keyEvent.vkCode == VK_F5) {
          sendHideoutCommand();
        }
      }
    });
  }

  void listenForPoeClientLog() async {
    clientLogFile = File("$poePath$clientLogFolderName/$clientLogFileName");

    // Reset Stream
    clientLogFileStream = null;
    clientLogFileStreamSubscription?.cancel();

    int index = 0;
    clientLogFileStream = clientLogFile?.openRead();
    clientLogFileStreamSubscription = clientLogFileStream?.listen(
      (chars) {
        index += chars.length;
      },
      onDone: () {
        clientLogLastIndex = index;
        if (kDebugMode) {
          print("Last Index: $clientLogLastIndex");
        }

        startProcessIncomingLogsLoop();
      },
    );
  }

  void startProcessIncomingLogsLoop() {
    String lineText = "";

    // Reset Stream
    clientLogFileStream = null;
    clientLogFileStreamSubscription?.cancel();

    clientLogFileStream = clientLogFile?.openRead(clientLogLastIndex);
    clientLogFileStreamSubscription = clientLogFileStream?.listen(
      (chars) {
        if (chars.isEmpty) {
          return;
        }
        clientLogLastIndex += chars.length;

        try {
          List<int> charsToBeDecode = [];
          for (var char in chars) {
            // _LF = 10, _CR = 13
            if ([10, 13].contains(char) && charsToBeDecode.isNotEmpty) {
              final line = utf8.decode(charsToBeDecode);
              charsToBeDecode = [];

              processLogLine(line);
            } else {
              charsToBeDecode.add(char);
            }
          }
        } catch (e) {
          print(e);
        }
      },
      onDone: () async {
        await Future.delayed(const Duration(seconds: 2));

        startProcessIncomingLogsLoop();
      },
    );
  }

  void processLogLine(String line) {
    final List<String> toMarkers = [
      "@To",
      "@An",
      "@${String.fromCharCode(0x00c0)}",
      "@Para",
      "@От",
      "@ถึง",
      "@Para",
      "@발신",
      "@向",
    ];

    final List<String> fromMarkers = [
      "@From",
      "@Von",
      "@De",
      "@De",
      "@Кому",
      "@จาก",
      "@De",
      "@수신",
      "@來自",
    ];

    print("Line: $line");
  }

  int getHWND() {
    return GetForegroundWindow();
  }

  String getWindowText(int hwnd) {
    final windowTextLength = GetWindowTextLength(hwnd);
    final windowTextBuffer = wsalloc(windowTextLength + 1);
    GetWindowText(hwnd, windowTextBuffer, windowTextLength + 1);
    final windowText = windowTextBuffer.toDartString();

    free(windowTextBuffer);

    return windowText;
  }

  int getProcessId(int hwnd) {
    final processIdBuffer = calloc<DWORD>();
    GetWindowThreadProcessId(hwnd, processIdBuffer);
    final processId = processIdBuffer.asTypedList(1).first;

    free(processIdBuffer);

    return processId;
  }

  String getPoePath() {
    final executionFileLocation = getExecutionFileLocation(poeProcessId);
    final poePathSplit = executionFileLocation.split("\\");
    poePathSplit.removeLast();
    final poePath = poePathSplit.join("\\");

    return "$poePath\\";
  }

  String getExecutionFileLocation(int processID) {
    // Get a handle to the process.
    final hProcess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, processID);

    // Get a list of all the modules in this process.
    final hMods = calloc<HMODULE>(1024);
    final cbNeeded = calloc<DWORD>();
    String executionFileName = "";

    if (EnumProcessModules(hProcess, hMods, sizeOf<HMODULE>() * 1024, cbNeeded) == 1) {
      for (var i = 0; i < (cbNeeded.value ~/ sizeOf<HMODULE>()); i++) {
        final szModName = wsalloc(MAX_PATH);

        // Get the full path to the module's file.
        final hModule = hMods.elementAt(i).value;

        if (GetModuleFileNameEx(hProcess, hModule, szModName, MAX_PATH) != 0) {
          if (szModName.toDartString().contains(".exe")) {
            executionFileName = szModName.toDartString();
            free(szModName);
            break;
          }
        }

        free(szModName);
      }
    }

    free(hMods);
    free(cbNeeded);

    // Release the handle to the process.
    CloseHandle(hProcess);

    return executionFileName;
  }

  void sendHideoutCommand() {
    if (kDebugMode) {
      print("Enter sendHideoutCommand");
    }

    _sendCommand(Command.hideout);
  }

  void sendInviteCommand(String characterName) {
    if (kDebugMode) {
      print("Enter sendInviteCommand");
    }

    _sendCommand(Command.invite.replaceAll("@name", characterName));
  }

  void sendKickCommand(String characterName) {
    if (kDebugMode) {
      print("Enter sendKickCommand");
    }

    _sendCommand(Command.kick.replaceAll("@name", characterName));
  }

  void _sendCommand(String command) {
    if (kDebugMode) {
      print("Enter sendCommand: $command");
    }

    SetForegroundWindow(poeHWND);

    _sendEnter();

    _sendSelectAll();

    for (int unicodeChar in utf8.encode(command)) {
      _sendChar(unicodeChar);
    }

    _sendEnter();
  }

  void _sendEnter() {
    if (kDebugMode) {
      print("Enter sendEnter");
    }

    final enterInput = calloc<INPUT>();
    enterInput.ref.type = INPUT_KEYBOARD;
    enterInput.ref.ki.wVk = VK_RETURN;
    SendInput(1, enterInput, sizeOf<INPUT>());

    enterInput.ref.ki.dwFlags = KEYEVENTF_KEYUP;
    SendInput(1, enterInput, sizeOf<INPUT>());

    free(enterInput);
  }

  void _sendSelectAll() {
    if (kDebugMode) {
      print("Enter sendSelectAll");
    }

    final controlInput = calloc<INPUT>();
    final aInput = calloc<INPUT>();

    controlInput.ref.type = INPUT_KEYBOARD;
    controlInput.ref.ki.wVk = VK_CONTROL;

    aInput.ref.type = INPUT_KEYBOARD;
    aInput.ref.ki.wVk = VkKeyScanEx("a".codeUnits.first, 0);

    SendInput(1, controlInput, sizeOf<INPUT>());
    SendInput(1, aInput, sizeOf<INPUT>());

    aInput.ref.ki.dwFlags = KEYEVENTF_KEYUP;
    SendInput(1, aInput, sizeOf<INPUT>());

    controlInput.ref.ki.dwFlags = KEYEVENTF_KEYUP;
    SendInput(1, controlInput, sizeOf<INPUT>());

    free(controlInput);
    free(aInput);
  }

  void _sendChar(int unicodeChar) {
    if (kDebugMode) {
      print("Enter sendChar");
    }

    final stringInput = calloc<INPUT>();
    stringInput.ref.type = INPUT_KEYBOARD;
    stringInput.ref.ki.dwFlags = KEYEVENTF_UNICODE;
    stringInput.ref.ki.wScan = unicodeChar;
    SendInput(1, stringInput, sizeOf<INPUT>());

    stringInput.ref.ki.dwFlags |= KEYEVENTF_KEYUP;
    SendInput(1, stringInput, sizeOf<INPUT>());

    free(stringInput);
  }
}
