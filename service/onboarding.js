// service/onboarding.js

const { Entity } = require('@drumee/server-core');
const { toArray } = require('@drumee/server-essentials');

class Onboarding extends Entity {

  _getUserId() {
    const userId = this.user?.id || this.session?.user?.id;
    if (!userId) {
      throw new Error("User ID not found in session.");
    }
    return userId;
  }

  async _checkStep1Completed(userId) {
    let result = await this.db.await_proc('1_c1d86df0c1d86df7.get_onboarding_response', userId);
    result = toArray(result)[0];

    if (!result || !result.first_name || !result.email) {
      throw new Error("Please complete Step 1 (User Info) first.");
    }
  }

  async save_user_info() {
    const userId = this._getUserId();

    // DEBUG: Log user ID
    console.log('[ONBOARDING DEBUG] userId:', userId);
    console.log('[ONBOARDING DEBUG] this.user:', this.user);
    console.log('[ONBOARDING DEBUG] this.session:', this.session);

    const firstName = this.input.get('first_name');
    const lastName = this.input.get('last_name');
    const email = this.input.get('email');
    const country = this.input.get('country');

    // DEBUG: Log parameters
    console.log('[ONBOARDING DEBUG] Parameters:', { userId, firstName, lastName, email, country });

    // Validate
    if (!firstName) throw new Error("First name is required.");
    if (!lastName) throw new Error("Last name is required.");
    if (!email) throw new Error("Email is required.");
    if (!country) throw new Error("Country is required.");

    // Call SP
    await this.db.await_proc( 
      '1_c1d86df0c1d86df7.save_onboarding_user_info',
      userId,
      firstName,
      lastName,
      email,
      country
    );

    this.output.data({
      success: true,
      message: 'User info saved.',
      data: {} 
    });
  }

  async save_usage_plan() {
    const userId = this._getUserId();

    const usagePlan = this.input.get('usage_plan');

    if (!usagePlan) throw new Error("Usage plan is required.");

    const validPlans = ['personal', 'team', 'storage', 'other'];
    if (!validPlans.includes(usagePlan)) {
      throw new Error(`Usage plan must be one of: ${validPlans.join(', ')}`);
    }

    await this.db.await_proc(
      '1_c1d86df0c1d86df7.save_onboarding_usage_plan',
      userId,
      usagePlan
    );

    this.output.data({
      success: true,
      message: 'Usage plan saved.',
      data: {} 
    });
  }

  async save_tools() {
    const userId = this._getUserId();

    const currentTools = this.input.get('current_tools');

    if (!Array.isArray(currentTools)) {
      throw new Error("current_tools must be an array.");
    }
    if (currentTools.length === 0) {
      throw new Error("Please select at least one tool.");
    }
    const validTools = ['notion', 'dropbox', 'google_drive', 'other'];
    const invalidTools = currentTools.filter(tool => !validTools.includes(tool));
    if (invalidTools.length > 0) {
      throw new Error(`Invalid tools: ${invalidTools.join(', ')}`);
    }

    const currentToolsJson = JSON.stringify(currentTools);

    await this.db.await_proc( 
      '1_c1d86df0c1d86df7.save_onboarding_tools',
      userId,
      currentToolsJson
    );

    this.output.data({
      success: true,
      message: 'Tools saved.',
      data: {} 
    });
  }

  async save_privacy() {
    const userId = this._getUserId();

    const privacyLevel = this.input.get('privacy_level');

    if (privacyLevel === null || privacyLevel === undefined) {
      throw new Error("Privacy level is required.");
    }
    const level = parseInt(privacyLevel);
    if (isNaN(level) || level < 1 || level > 5) {
      throw new Error("Privacy level must be between 1 and 5.");
    }

    await this.db.await_proc(
      '1_c1d86df0c1d86df7.save_onboarding_privacy',
      userId,
      level
    );

    this.output.data({
      success: true,
      message: 'Privacy level saved.',
      data: {} 
    });
  }

  async get_response() {
    const userId = this._getUserId();

    let responseData = await this.db.await_proc('1_c1d86df0c1d86df7.get_onboarding_response', userId);
    responseData = toArray(responseData)[0] || null;

    if (!responseData) {
      this.output.data({
        success: false,
        message: 'No onboarding data found.',
        data: null
      });
      return;
    }

    if (responseData.current_tools && typeof responseData.current_tools === 'string') {
        try {
            responseData.current_tools = JSON.parse(responseData.current_tools);
        } catch (e) {
            this.warn("Failed to parse current_tools JSON for user:", userId);
            responseData.current_tools = [];
        }
    }


    this.output.data({
      success: true,
      data: responseData
    });
  }


  async check_completion() {
    const userId = this._getUserId();

    let completionStatus = await this.db.await_proc('1_c1d86df0c1d86df7.check_onboarding_completion', userId);
    completionStatus = toArray(completionStatus)[0] || {
      user_id: userId,
      is_completed: false,
      status: 'not_started'
    };

    this.output.data({
      success: true,
      data: completionStatus
    });
  }

  async mark_complete() {
    const userId = this._getUserId();

    await this.db.await_proc('1_c1d86df0c1d86df7.mark_onboarding_complete', userId);

    this.output.data({
      success: true,
      message: 'Onboarding marked as complete (validated).',
      data: {}
    });
  }

}

module.exports = Onboarding;