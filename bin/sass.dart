// Copyright 2016 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:args/args.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:path/path.dart' as p;

import 'package:sass/src/ast/sass.dart';
import 'package:sass/src/exception.dart';
import 'package:sass/src/io.dart';
import 'package:sass/src/visitor/perform.dart';
import 'package:sass/src/visitor/serialize.dart';

void main(List<String> args) {
  var argParser = new ArgParser(allowTrailingOptions: true)
    ..addOption('precision', hide: true)
    ..addOption('style',
        abbr: 's',
        help: 'Output style.',
        allowed: ['expanded'],
        defaultsTo: 'expanded')
    ..addFlag('color',
        abbr: 'c', help: 'Whether to emit terminal colors.', defaultsTo: true)
    ..addFlag('trace', help: 'Print full Dart stack traces for exceptions.')
    ..addFlag('help',
        abbr: 'h', help: 'Print this usage information.', negatable: false);
  var options = argParser.parse(getArguments(args));

  if (options['help']) {
    print("Compile Sass to CSS.\n");
    print("Usage: sass <input>\n");
    print(argParser.usage);
    exit(64);
  }

  try {
    var file = options.rest.first;
    var contents = readFile(file);
    var url = p.toUri(file);
    var sassTree = p.extension(file) == '.sass'
        ? new Stylesheet.parseSass(contents, url: url)
        : new Stylesheet.parseScss(contents, url: url);
    var cssTree = new PerformVisitor().visitStylesheet(sassTree);
    var css = toCss(cssTree);
    if (css.isNotEmpty) print(css);
  } on SassException catch (error, stackTrace) {
    stderr.writeln(error.toString(color: options['color']));

    if (options['trace']) {
      stderr.writeln();
      stderr.write(new Trace.from(stackTrace).toString());
      stderr.flush();
    }

    exit(1);
  }
}
