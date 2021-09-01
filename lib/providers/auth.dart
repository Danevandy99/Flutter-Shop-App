import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/models/http_exception.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    return _expiryDate != null &&
            _expiryDate.isAfter(DateTime.now()) &&
            _token != null
        ? _token
        : null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(String email, password, String urlSegment) async {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyA2B42SCRBvwE8GYI7AtIXXZ2Lq3nbFoGo");

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );

      final responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      _autoLogout();
      notifyListeners();
      final preferences = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryData': _expiryDate.toIso8601String(),
      });
      preferences.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, "signUp");
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, "signInWithPassword");
  }

  Future<bool> tryAutoLogin() async {
    final preferences = await SharedPreferences.getInstance();
    if (!preferences.containsKey('userData')) {
      return false;
    } else {
      final extractedUserData = json.decode(preferences.getString('userData')) as Map<String, Object>;
      final expiryDate = DateTime.parse(extractedUserData['expiryData']);

      if (expiryDate.isBefore(DateTime.now())) {
        return false;
      } else {
        _token = extractedUserData['token'];
        _userId = extractedUserData['userId'];
        _expiryDate = expiryDate;
        notifyListeners();
        _autoLogout();
        return true;
      }
    }
  }

  void logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    final preferences = await SharedPreferences.getInstance();
    preferences.remove('userData');
    // *or* preferences.clear();
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    _authTimer = Timer(Duration(seconds: _expiryDate.difference(DateTime.now()).inSeconds),
        () {
          logout();
        });
  }
}
