// Copyright 2025 Gint Atkinson. All rights reserved.
// SPDX-License-Identifier: MIT

import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/domain_name_and_host_types.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DomainNameAndHostTypes value object', () {
    test('should_create_instance_with_four_fields', () {
      const model = DomainNameAndHostTypes(
        containerId: 'test-1',
        domainName: 'example.com',
        host: '192.0.2.1',
        uri: 'https://example.com/path',
      );
      expect(model.containerId, equals('test-1'));
      expect(model.domainName, equals('example.com'));
      expect(model.host, equals('192.0.2.1'));
      expect(model.uri, equals('https://example.com/path'));
    });

    test('should_use_default_containerId_when_not_specified', () {
      const model = DomainNameAndHostTypes();
      expect(model.containerId, equals('default'));
      expect(model.domainName, '');
      expect(model.host, '');
      expect(model.uri, '');
    });

    test('should_have_value_equality', () {
      const a = DomainNameAndHostTypes(
        domainName: 'example.com',
        host: '192.0.2.1',
      );
      const b = DomainNameAndHostTypes(
        domainName: 'example.com',
        host: '192.0.2.1',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('should_have_inequality_with_different_values', () {
      const a = DomainNameAndHostTypes(domainName: 'example.com');
      const b = DomainNameAndHostTypes(domainName: 'test.org');
      expect(a, isNot(equals(b)));
    });
  });

  group('validateDomainName', () {
    test('should_accept_valid_FQDN_example_dot_com', () {
      final result = validateDomainName('example.com');
      expect(result.isSuccess, isTrue);
      expect((result as Success<String>).value, equals('example.com'));
    });

    test('should_accept_root_domain_dot', () {
      final result = validateDomainName('.');
      expect(result.isSuccess, isTrue);
    });

    test('should_accept_single_label_localhost', () {
      final result = validateDomainName('localhost');
      expect(result.isSuccess, isTrue);
    });

    test('should_accept_fully_qualified_with_trailing_dot', () {
      final result = validateDomainName('subdomain.example.com.');
      expect(result.isSuccess, isTrue);
    });

    test('should_accept_SRV_record_format', () {
      final result = validateDomainName('_http._tcp.example.com');
      expect(result.isSuccess, isTrue);
    });

    test('should_accept_max_length_253_char_multi_label', () {
      const label = 'abcdefghijklmnopqrstuvwxyz0123456789abcdefghij'; // 48 chars
      const domain =
          '$label.$label.$label.$label.$label.abc'; // 48+1+48+1+48+1+48+1+48+1+3 = 248
      expect(domain.length, lessThanOrEqualTo(253));
      final result = validateDomainName(domain);
      expect(result.isSuccess, isTrue);
    });

    test('should_reject_zero_length_string', () {
      final result = validateDomainName('');
      expect(result.isFailure, isTrue);
      expect((result as Failure<String>).error,
          isA<DomainNameLengthExceededError>());
    });

    test('should_reject_length_exceeding_253_chars', () {
      const label = 'abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz0123456789ab'; // 64 chars
      const domain =
          '$label.$label.$label.$label'; // 64+1+64+1+64+1+64 = 259
      expect(domain.length, greaterThan(253));
      final result = validateDomainName(domain);
      expect(result.isFailure, isTrue);
      expect((result as Failure<String>).error,
          isA<DomainNameLengthExceededError>());
    });

    test('should_reject_label_exceeding_63_chars', () {
      const longLabel =
          'abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz0123'; // 65 chars
      final result = validateDomainName('$longLabel.com');
      expect(result.isFailure, isTrue);
      expect((result as Failure<String>).error,
          isA<InvalidLabelSyntaxError>());
    });

    test('should_reject_label_ending_with_hyphen', () {
      final result = validateDomainName('bad-.example.com');
      expect(result.isFailure, isTrue);
      expect((result as Failure<String>).error,
          isA<InvalidLabelSyntaxError>());
    });

    test('should_reject_label_starting_with_hyphen', () {
      final result = validateDomainName('-bad.example.com');
      expect(result.isFailure, isTrue);
      expect((result as Failure<String>).error,
          isA<InvalidLabelSyntaxError>());
    });

    test('should_reject_label_with_space', () {
      final result = validateDomainName('bad label.com');
      expect(result.isFailure, isTrue);
    });

    test('should_reject_label_with_exclamation', () {
      final result = validateDomainName('bad!label.com');
      expect(result.isFailure, isTrue);
    });

    test('should_accept_A_label_punycode_for_IDN', () {
      final result = validateDomainName('xn--fsq.example.com');
      expect(result.isSuccess, isTrue);
    });

    test('should_reject_double_dot_consecutive', () {
      final result = validateDomainName('bad..label.com');
      expect(result.isFailure, isTrue);
    });

    test('should_reject_string_with_only_hyphens', () {
      final result = validateDomainName('---');
      expect(result.isFailure, isTrue);
    });
  });

  group('canonicalizeDomainName', () {
    test('should_lowercase_uppercase_domain_name', () {
      final result = canonicalizeDomainName('EXAMPLE.COM');
      expect(result.isSuccess, isTrue);
      expect((result as Success<String>).value, equals('example.com'));
    });

    test('should_return_lowercase_unchanged', () {
      final result = canonicalizeDomainName('example.com');
      expect(result.isSuccess, isTrue);
      expect((result as Success<String>).value, equals('example.com'));
    });

    test('should_lowercase_mixed_case_domain', () {
      final result = canonicalizeDomainName('ExAmPlE.CoM');
      expect(result.isSuccess, isTrue);
      expect((result as Success<String>).value, equals('example.com'));
    });

    test('should_fail_for_invalid_input_before_canonicalizing', () {
      final result = canonicalizeDomainName('');
      expect(result.isFailure, isTrue);
    });
  });

  group('validateHost', () {
    test('should_accept_IPv4_address_as_host', () {
      final result = validateHost('192.0.2.1');
      expect(result.isSuccess, isTrue);
    });

    test('should_accept_IPv6_address_as_host', () {
      final result = validateHost('2001:db8::1');
      expect(result.isSuccess, isTrue);
    });

    test('should_accept_scoped_IPv6_address_as_host', () {
      final result = validateHost('fe80::1%eth0');
      expect(result.isSuccess, isTrue);
    });

    test('should_accept_domain_name_as_host', () {
      final result = validateHost('server01.network.internal');
      expect(result.isSuccess, isTrue);
    });

    test('should_reject_invalid_host_format', () {
      final result = validateHost('invalid_host_@#\$%.com');
      expect(result.isFailure, isTrue);
      expect((result as Failure<String>).error,
          isA<InvalidHostFormatError>());
    });
  });

  group('validateUri', () {
    test('should_accept_valid_HTTPS_URI', () {
      final result = validateUri('https://example.com/path');
      expect(result.isSuccess, isTrue);
    });

    test('should_accept_URI_with_query_and_fragment', () {
      final result =
          validateUri('https://example.com:8443/api/v1/resource?query=test#section1');
      expect(result.isSuccess, isTrue);
    });

    test('should_reject_zero_length_URI', () {
      final result = validateUri('');
      expect(result.isFailure, isTrue);
      expect(
          (result as Failure<String>).error, isA<UriZeroLengthError>());
    });

    test('should_reject_non_ASCII_unicode_URI', () {
      final result = validateUri('https://example.com/ñ');
      expect(result.isFailure, isTrue);
      expect(
          (result as Failure<String>).error, isA<UriNonAsciiError>());
    });

    test('should_accept_percent_encoded_non_ASCII', () {
      final result = validateUri('https://example.com/%C3%B1');
      expect(result.isSuccess, isTrue);
    });

    test('should_accept_data_scheme_URI', () {
      final result = validateUri('data:text/plain,hello');
      expect(result.isSuccess, isTrue);
    });

    test('should_reject_URI_with_raw_spaces', () {
      final result = validateUri('https://example.com/my path');
      expect(result.isFailure, isTrue);
    });
  });

  group('normalizeUri', () {
    test('should_lowercase_scheme_and_host', () {
      final result = normalizeUri(
          'HTTP://USER:PASS@EXAMPLE.COM:8080/path/%7Euser/default.html?query=1');
      expect(result.isSuccess, isTrue);
      expect((result as Success<String>).value,
          contains('http://USER:PASS@example.com:8080'));
    });

    test('should_decode_unreserved_percent_encoding', () {
      final result = normalizeUri('https://example.com/%7Euser/path');
      expect(result.isSuccess, isTrue);
      final normalized = (result as Success<String>).value;
      expect(normalized, contains('~user'));
      expect(normalized, isNot(contains('%7E')));
    });

    test('should_uppercase_hex_percent_encodings', () {
      final result = normalizeUri('https://example.com/%3apath');
      expect(result.isSuccess, isTrue);
      final normalized = (result as Success<String>).value;
      expect(normalized, contains('%3A'));
    });

    test('should_fail_for_invalid_input_before_normalizing', () {
      final result = normalizeUri('');
      expect(result.isFailure, isTrue);
    });

    test('should_normalize_complex_URI_from_spec_scenario_6', () {
      final result = normalizeUri(
          'HTTP://USER:PASS@EXAMPLE.COM:8080/path/%7Euser/default.html?query=1');
      expect(result.isSuccess, isTrue);
      final normalized = (result as Success<String>).value;
      expect(normalized, startsWith('http://'));
      expect(normalized, contains('example.com'));
      expect(normalized, contains('~user'));
    });
  });
}
