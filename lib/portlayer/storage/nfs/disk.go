// Copyright 2017 VMware, Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package nfs

import (
	"net/url"
)

//  Volume identifies an NFS based volume
type Volume struct {

	// This is the nfs host the the volume belongs to
	Host *url.URL

	// Path on the Host where the volume is located
	Path string
}

func NewVolume(host *url.URL, NFSPath string) Volume {
	v := Volume{
		Host: host,
		Path: NFSPath,
	}
	return v
}

func (v Volume) MountPath() (string, error) {
	return v.Path, nil
}

// DiskPath includes the url to the nfs directory for the container to mount,
func (v Volume) DiskPath() url.URL {
	if v.Host == nil {
		return url.URL{}
	}
	return *v.Host
}
