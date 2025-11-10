// service/signup.js

const { Entity } = require('@drumee/server-core');
const { Cache, Attr, sysEnv, Messenger, uniqueId } = require('@drumee/server-essentials');
const { resolve } = require('path');

class Signup extends Entity {

  initialize(opt) {
    super.initialize(opt);
    this.conf = Cache.getSysConf('ob_conf');
    let { db_name } = JSON.parse(this.conf);
    this.app_db = db_name;
  }

  /**
   * 
   */
  async get_info() {
    const sessionId = this.input.sid();
    let sql = `SELECT email, otp FROM ${this.app_db}.signup_data WHERE session_id=?`
    let { email, otp } = await this.db.await_query(sql, sessionId) || {};
    if (otp) {
      this.output.data({ email, otp: 0 });
    } else {
      this.output.data({ email, otp: 0 });
    }
  }

  /**
   * 
   */
  async save_info() {
    const sessionId = this.input.sid();
    const email = this.input.need(Attr.email);
    let user = await this.yp.await_proc("drumate_exists", email);
    if (user && user.email) {
      return this.output.data({ status: "user_exists", email });
    }
    // Call SP
    let status = await this.db.await_proc(
      `${this.app_db}.save_signup_info`,
      sessionId, email
    );
    const ulang = this.input.ua_language();
    let lex = Cache.lex(ulang)
    const { main_domain } = sysEnv();
    let data = {
      heading: lex._your_account_is_all_set,
      message: lex._your_otp_is_x.format(status.otp),
      link: `https://${main_domain}/-/`,
      signature: lex._drumee_team,
      reminder: lex._copyright.format(`${new Date().getFullYear()}`),
      hello: lex._hello_x.format(email || ""),
    }
    const msg = new Messenger({
      subject: lex._welcome_on_drumee,
      recipient: email,
      handler: this.exception.email,
    });

    let sent = 0;
    try {
      let tpl = resolve(__dirname, "./templates/otp.html")
      let html = msg.renderFrom(tpl, data)
      await msg.send({ html });
      sent = 1;
    } catch (e) {
      this.warn(e)
    }
    this.output.data({ status: 'ok', sent, email });
  }

  /**
   * The account schema is picked from the pool of hubs that are already created by offline process 
   */
  async _create_account(data) {
    const { main_domain: domain } = sysEnv();
    let {
      email,
      firstname,
      lastname,
      password,
    } = data;
    let username = firstname || email.split('@')[0];
    username = await this.yp.await_func("ensure_username", { username: username.toLowerCase(), domain });
    // username = username.replace(/[^a-zA-Z0-9]/g, '');
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
        await this.session.login({ ident: email, password }, 0);
        return { error: 0, failed, status: "ok" }
      } catch (e) {
        this.warn("Auto login failed", e)
        return { error: 1, failed, status: "internal_error" }
      }
    }
    return { error: 1, failed, status: "unexpected_error" }
  }

  /**
   * 
   */
  async verify_otp() {
    const sessionId = this.input.sid();
    const otp = this.input.need('otp');
    let sql = `SELECT email, otp FROM ${this.app_db}.signup_data WHERE session_id=? AND otp=?`
    let { email } = await this.db.await_query(sql, sessionId, otp) || {};
    if (email) {
      let data = await this.db.await_proc(`${this.app_db}.get_signup_info`, { email }) || {};
      this.debug("AAA:132", data.user)
      // if (data && data.user && data.user.email) {
      //   await this._create_account(data.user)
      // }
      this.output.data(data);
    } else {
      this.output.data({ success: false, message: 'User info not saved.', data: {} });
    }
  }

}

module.exports = Signup;