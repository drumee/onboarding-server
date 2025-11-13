/**
 * @license
 * Copyright 2024 Thidima SA. All Rights Reserved.
 * Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE, Version 3 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * https://www.gnu.org/licenses/agpl-3.0.html
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * =============================================================================
 */

const {
  sysEnv, uniqueId
} = require("@drumee/server-essentials");
const { Mfs } = require("@drumee/server-core");


class Account extends Mfs {

  /**
   * The account schema is picked from the pool of hubs that are already created by offline process 
   */
  async create_account(data) {
    const { main_domain: domain } = sysEnv();
    let {
      email,
      firstname = "",
      password,
    } = data;
    let username = firstname || email.split('@')[0];
    username = await this.yp.await_func("ensure_username", { username: username.toLowerCase(), domain });
    let a = firstname.split(/ +/)
    let lastname = "";
    if (a.length > 1) {
      firstname = a[0]
      a.shift()
      lastname = a.join(' ')
    }
    username = username.replace(/[^a-zA-Z0-9]/g, '');
    let profile = {
      username,
      sharebox: uniqueId(),
      otp: 0,
      category: "trial",
      profile_type: "trial",
      lang: this.user.language() || this.input.app_language(),
      firstname,
      lastname,
      email
    }

    let user = await this.yp.await_proc("drumate_create", password, profile);
    if (!user || !user[0]) {
      return { ...profile, error: 1, status: "unknown_error" }
    }

    if (user[0].failed) {
      return { ...profile, error: 1, status: "db_error", ...user[0] }
    }
    let { permission, failed } = user[0];
    let { drumate } = user[2] || {};
    if (drumate && permission) {
      try {
        let status = await this.session.signin({ ident: email, password });
        return status;
      } catch (e) {
        this.warn("Auto login failed", e)
        return { error: 1, failed, status: "internal_error" }
      }
    }
    return { error: 1, failed, status: "unexpected_error" }
  }
}

module.exports = Account;
