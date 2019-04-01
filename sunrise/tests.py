import unittest

from sunrise import settings


class TestSettings(unittest.TestCase):

    def test_allowed_hosts(self):
        # Test that if not in debug mode than allowed hosts is set.
        self.assertTrue(settings.DEBUG or len(settings.ALLOWED_HOSTS) > 0)

    def test_map_center(self):
        # Assert that map center is not none
        self.assertIsNotNone(settings.MAP_CENTER)
        # Assert that map center is a list of 2 values
        self.assertEqual(len(settings.MAP_CENTER), 2)

    def test_secret_key(self):
        # Assert that secret key is not none
        self.assertIsNotNone(settings.SECRET_KEY)
        # Assert that secret key is greater than or equal to 128
        self.assertGreaterEqual(len(settings.SECRET_KEY), 128)


if __name__ == '__main__':
    unittest.main()
