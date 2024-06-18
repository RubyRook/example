import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

enum Errors {error, notFound, maintenance, connection, exceedLimit, noInternet}

final dioConnection = [
  DioExceptionType.connectionError,
  DioExceptionType.connectionTimeout,
  DioExceptionType.receiveTimeout,
];

sealed class Status<T> {

}

final class LoadingState<T> extends Status<T> {
  Widget loadingWidget(){
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 128),
      child: const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}

final class CompletedState<T> extends Status<T>  {
  final T value;
  CompletedState(this.value);
}

final class ErrorState<T> extends Status<T>  {
  final Object e;
  final StackTrace? s;
  ErrorState(this.e, [this.s]){
    generateErrorMessage();
  }

  Response<dynamic>? response;

  String? title;
  String content = 'Something went wrong!';
  Errors type = Errors.error;

  void generateErrorMessage({bool check400 = false}) {
    // Todo 1. Response but error
    if(e is Response) {
      final e = this.e as Response;
      response = e;
      debugPrint("Status Code: ${e.statusCode}\nBody: ${e.data}");
      _responseBase(e, check400);
    }
    // Todo 2. DioException
    else if(e is DioException) {
      final e = this.e as DioException;
      response = e.response;
      debugPrintStack(label: e.response?.statusMessage, stackTrace: s);
      // Todo A. Connection Error
      if(dioConnection.contains(e.type)){
        type = Errors.connection;
        content = 'Connection error!';
      }
      // Todo B. Not Cancel
      else if(e.type != DioExceptionType.cancel){
        if(e.type == DioExceptionType.unknown && e.error is SocketException) {
          type = Errors.connection;
          content = 'Connection error!';
        }
        else if(e.response != null) {
          _responseBase(e.response!, check400);
        }
        else {
          type = Errors.error;
          content = 'Something went wrong!';
        }
      }
    }
    // Todo 3. FormatException
    else if(e.runtimeType == FormatException){
      debugPrintStack(stackTrace: s);
      type = Errors.error;
      content = "Cannot connect to server";
    }
    // Todo 4. Default
    else {
      debugPrintStack(stackTrace: s);
      type = Errors.error;
      content = 'Something went wrong!';
    }
  }

  void _responseBase(Response response, bool check400) {
    final json = response.tryDecodeAsMap ?? {};

    if(response.statusCode == 503){
      content = (json["message"] ?? 'Server maintenance').toString();
      type = Errors.maintenance;
    }
    else if(response.statusCode == 403){
      content = (json["message"] ?? "User is not authorized.").toString();
      type = Errors.error;
    }
    else if(response.statusCode == 404){
      content = (json["message"] ?? 'Page you looking for was not found').toString();
      type = Errors.notFound;
    }
    else {
      String? message;
      if(response.statusCode == 422){
        if(json["errors"] is Map){
          message = (json["errors"] as Map).values.join("\n");
        }
        else {
          message = (json["message"] ?? "Something went wrong").toString();
        }
      }
      else if(response.statusCode?.clamp(500, 600) == response.statusCode || (check400 && response.statusCode == 400)) {
        message = (json["message"] ?? "Something went wrong").toString();
      }

      if (message != null) content = message;
      type = Errors.error;
    }
  }

}

extension Decode on Response {
  Map? get tryDecodeAsMap {
    if (data is Map) {
      return data as Map;
    }

    try {
      return jsonDecode(data.toString());
    } on FormatException {
      return null;
    }
  }

  List? get tryDecodeAsList {
    if (data is List) {
      return data as List;
    }

    try {
      return jsonDecode(data.toString());
    } on FormatException {
      return null;
    }
  }
}