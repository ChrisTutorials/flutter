import 'dart:io';

import 'package:args/args.dart';
import 'package:store_screenshots/store_screenshots.dart';

void main(List<String> args) {
  final parser = ArgParser()
    ..addCommand('process')
    ..addCommand('validate');

  ArgResults results;
  try {
    results = parser.parse(args);
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    stderr.writeln(_usage(parser));
    exitCode = 64;
    return;
  }

  final command = results.command;
  if (command == null || command.arguments.isEmpty) {
    stderr.writeln(_usage(parser));
    exitCode = 64;
    return;
  }

  final specPath = command.arguments.first;
  final spec = ScreenshotWorkflowSpec.fromFile(specPath);
  final processor = ScreenshotProcessor();
  final validator = ScreenshotValidator(processor: processor);

  switch (command.name) {
    case 'process':
      final processed = processor.processSpec(spec);
      for (final result in processed) {
        stdout.writeln(
          'processed ${result.imageSpec.id}: ${result.outputFile.path} (${result.cropRect})',
        );
      }
      final issues = validator.validateSpec(spec);
      if (issues.isEmpty) {
        stdout.writeln('validation passed');
      } else {
        for (final issue in issues) {
          stderr.writeln(issue);
        }
        exitCode = 1;
      }
      return;
    case 'validate':
      final issues = validator.validateSpec(spec);
      if (issues.isEmpty) {
        stdout.writeln('validation passed');
      } else {
        for (final issue in issues) {
          stderr.writeln(issue);
        }
        exitCode = 1;
      }
      return;
  }
}

String _usage(ArgParser parser) {
  final buffer = StringBuffer()
    ..writeln('Usage: dart run bin/store_screenshots.dart <command> <spec.json>')
    ..writeln('')
    ..writeln('Commands:')
    ..writeln('  process   Crop, resize, and validate screenshots from raw inputs.')
    ..writeln('  validate  Validate already-exported screenshots against the spec.')
    ..writeln('')
    ..write(parser.usage);
  return buffer.toString();
}
