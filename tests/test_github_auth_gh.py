"""Exercise gh routing without credentials, network access, or real mutations."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SOURCE = Path(__file__).resolve().parents[1] / 'dot_zsh/github-auth.zsh'


class GhRoutingTest(unittest.TestCase):
    def invoke(self, args):
        with tempfile.TemporaryDirectory() as directory:
            mock = Path(directory) / 'ghtkn'
            mock.write_text('#!/usr/bin/env python3\nimport json, os, sys\n'
                            'print(json.dumps([os.environ["GHTKN_GIT_APP"], sys.argv[1:]]))\n')
            mock.chmod(0o755)
            env = dict(os.environ, PATH=directory + ':' + os.environ['PATH'],
                       GHTKN_GIT_APP_READ='test/read', GHTKN_GIT_APP_WRITE='test/write')
            return subprocess.run(
                ['/bin/zsh', '-f', '-c', 'source "$1"; shift; gh "$@"',
                 'test', str(SOURCE), *args], env=env, text=True, capture_output=True)

    def test_routing_and_original_arguments(self):
        cases = [
            ('write', ['repo', 'create', 'sample']),
            ('write', ['repo', 'new', 'sample']),
            ('write', ['-R', 'owner/repo', 'release', 'upload', 'v1', 'a b.zip']),
            ('write', ['repo', '--repo=owner/repo', 'rename', 'new-name']),
            ('write', ['repo', 'deploy-key', 'add', 'key.pub']),
            ('write', ['repo', 'autolink', 'delete', '1']),
            ('write', ['issue', 'pin', '1']),
            ('write', ['label', 'clone', 'owner/source']),
            ('write', ['secret', 'set', 'NAME', '--body', 'literal $value']),
            ('write', ['project', 'item-add', '1']),
            ('write', ['cache', 'delete', '--all']),
            ('write', ['api', 'graphql', '-f', 'query=query { viewer { login } }']),
            ('write', ['--hostname', 'github.com', 'api', 'repos/o/r', '-XPATCH']),
            ('read', ['api', 'repos/o/r', '-XGET', '-f', 'q=x']),
            ('read', ['repo', 'deploy-key', 'list']),
            ('read', ['repo', 'autolink', 'list']),
            ('read', ['repo', 'view', '--json', 'name']),
            ('read', ['release', 'download', 'v1']),
            ('read', ['secret', 'list']),
            ('read', ['project', 'item-list', '1']),
            ('read', ['extension', 'exec', 'custom']),
            ('read', ['custom-alias']),
        ]
        for role, args in cases:
            with self.subTest(args=args):
                result = self.invoke(args)
                self.assertEqual(result.returncode, 0, result.stderr)
                app = 'test/' + role
                self.assertEqual(json.loads(result.stdout),
                                 [app, ['exec', '-e', 'GH_TOKEN:' + app, '--', 'gh', *args]])

    def test_auth_guards_with_leading_options(self):
        for operation in ('login', 'token'):
            result = self.invoke(['--hostname=github.com', 'auth', operation])
            self.assertEqual(result.returncode, 1)
            self.assertEqual(result.stdout, '')


if __name__ == '__main__':
    unittest.main()
