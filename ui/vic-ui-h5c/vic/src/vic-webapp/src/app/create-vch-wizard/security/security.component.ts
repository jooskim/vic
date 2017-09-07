/*
 Copyright 2017 VMware, Inc. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
*/
import { Component, Input } from '@angular/core';
import { FormArray, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/observable/timer';
import { CreateVchWizardService } from '../create-vch-wizard.service';
import {
  numberPattern,
  fqdnPattern,
  cidrPattern,
  wildcardDomainPattern,
  ipPattern,
  whiteListRegistryPattern
} from '../../shared/utils/validators';

@Component({
  selector: 'vic-vch-creation-security',
  templateUrl: './security.html',
  styleUrls: ['./security.scss']
})
export class SecurityComponent {
  public form: FormGroup;
  public formErrMessage = '';
  public inAdvancedMode = false;
  public signpostOpenState = false;
  public fileReaderError: string = null;
  // internal array that keeps track of TLS CA files' name and content
  public tlsCaContents: any[] = [];
  // internal array that keeps track of registry CA files' name and content
  public registryCaContents: any[] = [];
  private _isSetup = false;
  @Input() vchName: string;

  constructor(
    private formBuilder: FormBuilder,
    private createWzService: CreateVchWizardService
  ) {
    this.form = formBuilder.group({
      useTls: true,
      tlsCertPath: ['', Validators.required],
      serverCertSource: 'autogenerated',
      tlsCname: '',
      organization: '',
      certificateKeySize: ['2048', [
        Validators.required,
        Validators.pattern(numberPattern)
      ]],
      tlsServerCert: '',
      tlsServerKey: '',
      useClientAuth: true,
      clientCertSource: 'autogenerated',
      tlsCas: formBuilder.array([this.createNewFormArrayEntry('tlsCas')]),
      useWhitelistRegistry: false,
      insecureRegistries: formBuilder.array([this.createNewFormArrayEntry('insecureRegistries')]),
      whitelistRegistries: formBuilder.array([this.createNewFormArrayEntry('whitelistRegistries')]),
      registryCas: formBuilder.array([this.createNewFormArrayEntry('registryCas')]),
      opsUser: ''
    });

    // Since useWhitelistRegistry is false by default, disable whitelistRegistries validations
    this.form.get('whitelistRegistries').disable();
  }

  addNewFormArrayEntry(controlName: string) {
    const control = this.form.get(controlName) as FormArray;
    if (!control) {
      return;
    }
    control.push(this.createNewFormArrayEntry(controlName));
  }

  createNewFormArrayEntry(controlName: string) {
    if (controlName === 'tlsCas') {
      return this.formBuilder.group({
        tlsCa: ''
      });
    } else if (controlName === 'insecureRegistries') {
      return this.formBuilder.group({
        insecureRegistryIp: '',
        insecureRegistryPort: ''
      });
    } else if (controlName === 'whitelistRegistries') {
      return this.formBuilder.group({
        whitelistRegistry: ['', [
          Validators.required,
          Validators.pattern(whiteListRegistryPattern)
        ]],
        whitelistRegType: 'secure'
      });
    } else if (controlName === 'registryCas') {
      return this.formBuilder.group({
        registryCa: ''
      });
    }
  }

  removeFormArrayEntry(controlName: string, index: number) {
    const control = this.form.get(controlName) as FormArray;
    if (!control) {
      return;
    }

    if (controlName === 'tlsCas') {
      if (index > 0 || (index === 0 && control.controls.length > 1)) {
        // remove the input control only if the current control is not the first one
        // and splice the internal array
        control.removeAt(index);
        this.tlsCaContents.splice(index, 1);
      } else {
        // clear the input and shift the internal array
        this.tlsCaContents.shift();
        control.controls[index].reset();
      }
    } else if (controlName === 'registryCas') {
      if (index > 0 || (index === 0 && control.controls.length > 1)) {
        control.removeAt(index);
        this.registryCaContents.splice(index, 1);
      } else {
        this.registryCaContents.shift();
        control.controls[index].reset();
      }
    } else {
      control.removeAt(index);
    }
  }

  onPageLoad() {
    if (this._isSetup) {
      return;
    }

    this.form.get('tlsCertPath').setValue(`./${this.vchName}/`);
    this.form.get('organization').setValue(this.vchName);

    this.form.get('useTls').valueChanges
      .subscribe(v => {
        if (v) {
          this.form.get('tlsCertPath').enable();
          this.form.get('certificateKeySize').enable();
        } else {
          this.form.get('tlsCertPath').disable();
          this.form.get('certificateKeySize').disable();
        }
      });

    this.form.get('useWhitelistRegistry').valueChanges
      .subscribe(v => {
        if (v) {
          this.form.get('whitelistRegistries').enable();
        } else {
          this.form.get('whitelistRegistries').disable();
        }
      });

    this._isSetup = true;
  }

  onCommit(): Observable<any> {
    const errs: string[] = [];
    const results: any = {};

    const useTlsValue = this.form.get('useTls').value;
    const serverCertSourceValue = this.form.get('serverCertSource').value;
    const clientCertSourceValue = this.form.get('clientCertSource').value;

    const tlsCnameValue = this.form.get('tlsCname').value;
    const orgValue = this.form.get('organization').value;
    const certKeySizeValue = this.form.get('certificateKeySize').value;
    const tlsServerCertValue = this.form.get('tlsServerCert').value;
    const tlsServerKeyValue = this.form.get('tlsServerKey').value;

    const useClientAuthValue = this.form.get('useClientAuth').value;
    const tlsCasValue = this.form.get('tlsCas').value;

    if (this.inAdvancedMode) {
      // Docker API Access
      if (!useTlsValue) {
        // if tls is off, use --no-tls
        results['noTls'] = true;
      } else {
        results['tlsCertPath'] = `./${this.vchName}/`;
        if (serverCertSourceValue === 'autogenerated') {
          if (tlsCnameValue) {
            results['tlsCname'] = tlsCnameValue;
          }
          if (orgValue) {
            results['organization'] = orgValue;
          }
          if (certKeySizeValue) {
            results['certificateKeySize'] = certKeySizeValue;
          }
        } else {
          results['tlsServerCert'] = tlsServerCertValue;
          results['tlsServerKey'] = tlsServerKeyValue;
        }

        if (!useClientAuthValue) {
          results['noTlsverify'] = true;
          results['tlsCa'] = [];
        } else {
          results['tlsCa'] = clientCertSourceValue === 'existing' ?
            this.tlsCaContents : [];
        }
      }

      // Registry Access
      const useWhitelistRegistryValue = this.form.get('useWhitelistRegistry').value;
      const insecureRegistriesValue = this.form.get('insecureRegistries').value;
      const whitelistRegistriesValue = this.form.get('whitelistRegistries').value;
      const registryCasValue = this.form.get('registryCas').value;

      if (!useWhitelistRegistryValue) {
        results['whitelistRegistry'] = [];
        results['insecureRegistry'] = insecureRegistriesValue.filter(val => {
          return val['insecureRegistryIp'] && val['insecureRegistryPort'];
        }).map(val => `${val['insecureRegistryIp']}:${val['insecureRegistryPort']}`);
      } else {
        const white = [];
        const insecure = [];
        whitelistRegistriesValue.filter(val => {
          return val['whitelistRegistry'];
        }).forEach(val => {
          if (val['whitelistRegType'] === 'secure') {
            white.push(val['whitelistRegistry']);
          } else {
            insecure.push(val['whitelistRegistry']);
          }
        });

        results['whitelistRegistry'] = white;
        results['insecureRegistry'] = insecure;
      }

      results['registryCa'] = this.registryCaContents;

      // Operations User
      const opsUserValue = this.form.get('opsUser').value;
      if (opsUserValue) {
        results['opsUser'] = opsUserValue;
      }
    }


    // user id, vc thumbprint and target
    results['user'] = this.createWzService.getUserId();
    results['thumbprint'] = this.createWzService.getServerThumbprint();
    results['target'] = this.createWzService.getVcHostname();

    return Observable.of({ security: results });
  }

  toggleAdvancedMode() {
    this.inAdvancedMode = !this.inAdvancedMode;
  }

  /**
   * On Change event read the content of the file and add it to the
   * corresponding array or overwrite the value at the given index
   * @param {Event} evt change event on file input
   * @param {string} targetField used to determine which array to push data to
   * @param {number} index FormArray index
   */
  addFileContent(evt: Event, targetField: string, index: number) {
    const fr = new FileReader();
    const fileList: FileList = evt.target['files'];
    const filereaderOnloadFactory = (filename: string) => {
      return () => {
        let targetArray: any[];
        if (targetField === 'tlsCas') {
          targetArray = this.tlsCaContents;
        } else if (targetField === 'registryCas') {
          targetArray = this.registryCaContents;
        }

        if (targetArray[index]) {
          // overwrite if value already exists at this index
          targetArray[index] = {
            name: filename,
            content: fr.result
          };
        } else {
          targetArray.push({
            name: filename,
            content: fr.result
          });
        }
      };
    };

    // since input is without the 'multiple' attribute we are sure that
    // only one entry will be available under FileList
    const fileInstance: File = fileList[0];

    // TODO: i18n-ify
    this.fileReaderError = fileInstance ? null : 'FileReader failed to load the file!';
    fr.onload = filereaderOnloadFactory(fileInstance.name);
    fr.readAsText(fileInstance);
  }

  /**
   * Clear the file reader error message. This method is called when clr-tab's
   * clrTabsCurrentTabContentChanged event is fired
   */
  clearFileReaderError() {
    this.fileReaderError = null;
  }
}
