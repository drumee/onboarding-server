// service/onboarding.js

const { Entity } = require('@drumee/server-core');
const { toArray, Cache } = require('@drumee/server-essentials');

class Onboarding extends Entity {

  initialize(opt) {
    super.initialize(opt);
    this.conf = Cache.getSysConf('ob_conf');
    console.log("Onboarding Service Initialized. Config:", this.conf);
  }

  // Session ID
  _getSessionId() {
    const sessionId = this.session?.id || this.input?.sessionId || this.req?.session?.id;
    if (!sessionId) {
      console.error('[ONBOARDING ERROR] Session ID not found. Context:', { user: this.user, session: this.session, input: this.input });
      throw new Error("Session ID not found.");
    }
    return sessionId;
  }

  async get_env() {
    console.log("[ONBOARDING] get_env called. Returning config:", this.conf); 
    this.output.data(this.conf || {}); 
  }

  async save_user_info() {
    const sessionId = this._getSessionId();
    const firstName = this.input.get('first_name');
    const lastName = this.input.get('last_name');
    const email = this.input.get('email');
    const countryCode = this.input.get('country_code');

    // Basic Validation
    if (!firstName || !lastName || !email || !countryCode) {
        throw new Error("Missing required user info fields.");
    }

    // Call SP
    await this.db.await_proc(
      '1_c1d86df0c1d86df7.save_onboarding_user_info',
      sessionId, firstName, lastName, email, countryCode
    );

    this.output.data({ success: true, message: 'User info saved.', data: {} });
  }

  async get_countries() {
    const requestedLocale = this.input.get('locale_code') || this.session?.locale || 'en_US'; 

    let countriesListRaw;
    try {
        countriesListRaw = await this.db.await_proc(
            '1_c1d86df0c1d86df7.get_countries', 
            requestedLocale 
        );
    } catch (spError) {
        console.error(`[ONBOARDING ERROR] Error calling get_countries SP: ${spError.message}`);
        throw spError;
    }

    const countriesList = toArray(countriesListRaw);

    this.output.data({ 
      success: true,
      data: countriesList 
    });
  }

  async save_usage_plan() {
    const sessionId = this._getSessionId();
    const usagePlan = this.input.get('usage_plan');

    if (!usagePlan) throw new Error("Usage plan is required.");
    const validPlans = ['personal', 'team', 'storage', 'other'];
    if (!validPlans.includes(usagePlan)) {
      throw new Error(`Usage plan must be one of: ${validPlans.join(', ')}`);
    }

    // Call SP
    await this.db.await_proc(
      '1_c1d86df0c1d86df7.save_onboarding_usage_plan',
      sessionId, usagePlan
    );

    this.output.data({ success: true, message: 'Usage plan saved.', data: {} });
  }

  async save_tools() {
    const sessionId = this._getSessionId();
    const currentTools = this.input.get('current_tools');

    if (!Array.isArray(currentTools)) throw new Error("current_tools must be an array.");
    if (currentTools.length === 0) throw new Error("Please select at least one tool.");
    // Add validation for tool names if needed

    const currentToolsJson = JSON.stringify(currentTools);

    // Call SP
    await this.db.await_proc(
      '1_c1d86df0c1d86df7.save_onboarding_tools',
      sessionId, currentToolsJson
    );

    this.output.data({ success: true, message: 'Tools saved.', data: {} });
  }

  async save_privacy() {
    const sessionId = this._getSessionId();
    const privacyLevel = this.input.get('privacy_level');

    if (privacyLevel === null || privacyLevel === undefined) throw new Error("Privacy level is required.");
    const level = parseInt(privacyLevel);
    if (isNaN(level) || level < 1 || level > 5) throw new Error("Privacy level must be between 1 and 5.");

    // Call SP
    await this.db.await_proc(
      '1_c1d86df0c1d86df7.save_onboarding_privacy',
      sessionId, level
    );

    this.output.data({ success: true, message: 'Privacy level saved.', data: {} });
  }

  async get_response() {
    const sessionId = this._getSessionId();
    let responseDataRaw;

    try {
      responseDataRaw = await this.db.await_proc('1_c1d86df0c1d86df7.get_onboarding_response', sessionId);
    } catch (spError) {
       console.error(`[ONBOARDING ERROR] Error calling get_response SP for session ${sessionId}: ${spError.message}`);
       throw spError; 
    }

    let responseData = toArray(responseDataRaw)[0] || null;

    if (!responseData) {
      this.output.data({ success: false, message: 'No onboarding data found.', data: null });
      return;
    }

    // Parse JSON tools
    if (responseData.current_tools && typeof responseData.current_tools === 'string') {
        try {
            responseData.current_tools = JSON.parse(responseData.current_tools);
        } catch (e) {
            this.warn("Failed to parse current_tools JSON for session:", sessionId);
            responseData.current_tools = [];
        }
    }

    this.output.data({ success: true, data: responseData });
  }

  async check_completion() {
    const sessionId = this._getSessionId();
    let completionStatusRaw;

    try {
        completionStatusRaw = await this.db.await_proc('1_c1d86df0c1d86df7.check_onboarding_completion', sessionId);
    } catch (spError) {
        console.error(`[ONBOARDING ERROR] Error calling check_completion SP for session ${sessionId}: ${spError.message}`);
        throw spError;
    }

    let completionStatus = toArray(completionStatusRaw)[0] || {
      // Return a default structure if SP returns nothing (user not started)
      session_id: sessionId,
      is_completed: false,
      status: 'not_started',
      steps_completed: null // Match SP output when not started
    };

    this.output.data({ success: true, data: completionStatus });
  }

  async mark_complete() {
    const sessionId = this._getSessionId();

    try {
        await this.db.await_proc('1_c1d86df0c1d86df7.mark_onboarding_complete', sessionId);
    } catch (spError) {
        console.error(`[ONBOARDING ERROR] Error calling mark_complete SP for session ${sessionId}: ${spError.message}`);
        throw spError; // Let API fail if validation in SP fails
    }

    this.output.data({ success: true, message: 'Onboarding marked as complete (validated).', data: {} });
  }
}

module.exports = Onboarding;