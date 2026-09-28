"""Pruebas de reemplazo confinadas a directorios temporales."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]

class BootstrapTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='guts-test-')
        self.base = Path(self.temp.name)
        self.home = self.base / 'home with spaces'
        self.home.mkdir()
        self.repo = self.base / 'repo with spaces'
        (self.repo / 'install').mkdir(parents=True)
        for name in ('bootstrap.sh', 'lib.sh', 'versions.sh'):
            shutil.copy2(ROOT / 'install' / name, self.repo / 'install' / name)
        for name in ('nvim', 'kitty', 'zsh'):
            (self.repo / name).mkdir()
        (self.repo / 'zsh/.zshrc').write_text('# managed\n')
        self.config = self.home / '.config'
        self.config.mkdir()
        self.env = dict(os.environ, HOME=str(self.home), XDG_CONFIG_HOME=str(self.config), DOTFILES_ALLOW_ROOT='1')

    def tearDown(self):
        self.temp.cleanup()

    def run_bootstrap(self, success=True):
        p = subprocess.run(['bash', str(self.repo / 'install/bootstrap.sh'), '--link-only'], env=self.env, capture_output=True, text=True)
        if success:
            self.assertEqual(p.returncode, 0, p.stdout + p.stderr)
        else:
            self.assertNotEqual(p.returncode, 0)
        return p

    def assert_links(self):
        for src, dst in [('zsh/.zshrc', self.home / '.zshrc'), ('nvim', self.config / 'nvim'), ('kitty', self.config / 'kitty')]:
            self.assertTrue(dst.is_symlink())
            self.assertEqual(dst.resolve(), self.repo / src)

    def test_fresh_and_second_run_preserves_link(self):
        self.run_bootstrap()
        self.assert_links()
        inode = (self.home / '.zshrc').lstat().st_ino
        self.run_bootstrap()
        self.assertEqual(inode, (self.home / '.zshrc').lstat().st_ino)
        self.assert_links()

    def test_existing_files_and_directories_replaced(self):
        (self.home / '.zshrc').write_text('old')
        (self.config / 'nvim').mkdir()
        (self.config / 'nvim/old.lua').write_text('old')
        (self.config / 'kitty').write_text('old')
        self.run_bootstrap()
        self.assert_links()
        self.assertFalse(list(self.home.rglob('*.backup*')))
        self.assertFalse((self.repo / 'nvim/old.lua').exists())

    def test_broken_link_replaced(self):
        (self.home / '.zshrc').symlink_to(self.base / 'missing')
        self.run_bootstrap()
        self.assert_links()

    def test_wrong_link_target_is_not_deleted(self):
        other = self.base / 'valuable'
        other.mkdir()
        (other / 'keep').write_text('keep')
        (self.config / 'nvim').symlink_to(other, target_is_directory=True)
        self.run_bootstrap()
        self.assertEqual((other / 'keep').read_text(), 'keep')
        self.assert_links()

    def test_missing_source_stops_before_any_replacement(self):
        (self.home / '.zshrc').write_text('keep')
        (self.repo / 'kitty').rmdir()
        self.run_bootstrap(False)
        self.assertEqual((self.home / '.zshrc').read_text(), 'keep')

    def test_refuses_to_remove_repository_ancestor(self):
        nested = self.config / 'nvim/repository'
        nested.parent.mkdir()
        shutil.move(self.repo, nested)
        self.repo = nested
        (self.home / '.zshrc').write_text('keep')
        self.run_bootstrap(False)
        self.assertTrue((self.repo / 'install/bootstrap.sh').exists())
        self.assertEqual((self.home / '.zshrc').read_text(), 'keep')

    def test_custom_config_parent_symlink(self):
        real = self.base / 'real-config'
        real.mkdir()
        self.config.rmdir()
        self.config.symlink_to(real, target_is_directory=True)
        self.run_bootstrap()
        self.assert_links()

    def test_unknown_argument_fails_without_changes(self):
        p = subprocess.run(['bash', str(self.repo / 'install/bootstrap.sh'), '--unknown'], env=self.env, capture_output=True)
        self.assertNotEqual(p.returncode, 0)
        self.assertFalse((self.home / '.zshrc').exists())

if __name__ == '__main__':
    unittest.main(verbosity=2)
