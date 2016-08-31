import os.path
import pexpect

class VicUiInstallPexpectLibrary(object):
    TIMEOUT_LIMIT = 180
    INSTALLER_PATH = os.path.join(os.path.dirname(__file__), '../../..', 'ui', 'installer', 'VCSA')

    def __init__(self):
        self._status = ''

    def _prepare_and_spawn(self, operation, callback, force=False):
        try:
            executable = os.path.join(VicUiInstallPexpectLibrary.INSTALLER_PATH, operation + '.sh')
            if force:
                executable += ' --force'

            self._f = open(operation + '.log', 'wb')
            self._pchild = pexpect.spawn(executable, cwd = VicUiInstallPexpectLibrary.INSTALLER_PATH, timeout = VicUiInstallPexpectLibrary.TIMEOUT_LIMIT)
            self._pchild.logfile = self._f
            callback()
            self._f.close()

        except IOError as e:
            return 'Error: ' + e.value

    def _common_prompts(self, vcenter_user, vcenter_password, root_password, is_vc55=None):
	self._pchild.expect('Enter your vCenter Administrator Username: ')
	self._pchild.sendline(vcenter_user)
	self._pchild.expect('Enter your vCenter Administrator Password: ')
	self._pchild.sendline(vcenter_password)
        if is_vc55 != None:
	    self._pchild.expect('Are you running.*')
	    self._pchild.sendline(is_vc55)

    def install_vicui_without_webserver(self, vcenter_user, vcenter_password, root_password, is_vc55, force=False):
        def commands():
            self._common_prompts(vcenter_user, vcenter_password, root_password, is_vc55)
            self._pchild.expect('root@.*')
            self._pchild.sendline(root_password)
            self._pchild.expect('root@.*')
            self._pchild.sendline(root_password)
            self._pchild.expect('root@.*')
            self._pchild.sendline(root_password)
            self._pchild.interact()

        self._prepare_and_spawn('install', commands, force)

    def install_vicui_without_webserver_nor_bash(self, vcenter_user, vcenter_password, root_password, is_vc55):
        def commands():
            self._common_prompts(vcenter_user, vcenter_password, root_password, is_vc55)
            self._pchild.expect('root@.*')
            self._pchild.sendline(root_password)
            self._pchild.expect('.*When all done.*')
            self._pchild.interact()

        self._prepare_and_spawn('install', commands)

    def install_fails_at_extension_reg(self, vcenter_user, vcenter_password, root_password, is_vc55=None):
        def commands():
            # web server is used when if is_vc55 is None
            self._common_prompts(vcenter_user, vcenter_password, root_password, is_vc55)
            if is_vc55 != None:
		self._pchild.expect('root@.*')
		self._pchild.sendline(root_password)

            self._pchild.expect('.*Error.*')
            self._pchild.interact()

        self._prepare_and_spawn('install', commands)

    def uninstall_fails(self, vcenter_user, vcenter_password):
        def commands():
            self._common_prompts(vcenter_user, vcenter_password, None)
            self._pchild.expect('.*Error.*')
            self._pchild.interact()

        self._prepare_and_spawn('uninstall', commands)

    def uninstall_vicui(self, vcenter_user, vcenter_password):
        def commands():
            self._common_prompts(vcenter_user, vcenter_password, None, None)
            self._pchild.expect(['.*successful', 'Error! Could not unregister.*'])
            self._pchild.interact()

        self._prepare_and_spawn('uninstall', commands)
