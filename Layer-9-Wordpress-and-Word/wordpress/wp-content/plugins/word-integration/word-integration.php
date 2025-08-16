<?php
/**
 * Plugin Name: Word Integration via Make.com
 * Description: Integrate WordPress with Make.com webhooks for Word document editing
 * Version: 1.0.0
 * Author: Universal DB
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

class WordIntegrationMakecom {
    
    private $webhook_url;
    
    public function __construct() {
        add_action('init', array($this, 'init'));
        add_action('admin_menu', array($this, 'add_admin_menu'));
        add_action('admin_init', array($this, 'settings_init'));
        add_shortcode('word_integration', array($this, 'shortcode_handler'));
        add_action('wp_ajax_word_integration_action', array($this, 'handle_ajax_request'));
        add_action('wp_ajax_nopriv_word_integration_action', array($this, 'handle_ajax_request'));
        add_action('wp_enqueue_scripts', array($this, 'enqueue_scripts'));
    }
    
    public function init() {
        $this->webhook_url = get_option('word_integration_webhook_url', '');
    }
    
    public function enqueue_scripts() {
        wp_enqueue_script('jquery');
        wp_enqueue_script('word-integration-js', plugin_dir_url(__FILE__) . 'word-integration.js', array('jquery'), '1.0.0', true);
        wp_localize_script('word-integration-js', 'word_integration_ajax', array(
            'ajax_url' => admin_url('admin-ajax.php'),
            'nonce' => wp_create_nonce('word_integration_nonce')
        ));
    }
    
    public function add_admin_menu() {
        add_options_page(
            'Word Integration Settings',
            'Word Integration',
            'manage_options',
            'word-integration',
            array($this, 'admin_page')
        );
    }
    
    public function settings_init() {
        register_setting('word_integration_settings', 'word_integration_webhook_url');
        add_settings_section(
            'word_integration_section',
            'Make.com Webhook Configuration',
            array($this, 'settings_section_callback'),
            'word_integration_settings'
        );
        add_settings_field(
            'webhook_url',
            'Webhook URL',
            array($this, 'webhook_url_field'),
            'word_integration_settings',
            'word_integration_section'
        );
    }
    
    public function settings_section_callback() {
        echo '<p>Configure your Make.com webhook settings below:</p>';
    }
    
    public function webhook_url_field() {
    $value = get_option('word_integration_webhook_url', '');
    echo '<input type="url" name="word_integration_webhook_url" value="' . esc_attr($value) . '" class="regular-text" placeholder="https://hook.integromat.com/your-webhook-url" />';
    echo '<p class="description">Enter your Make.com Custom Webhook URL</p>';
    }
    
    public function api_key_field() {
    // API Key field removed
    }
    
    public function admin_page() {
        ?>
        <div class="wrap word-integration-admin-panel">
            <h1 style="margin-bottom:24px;">Word Integration Settings</h1>
            <form method="post" action="options.php">
                <?php settings_fields('word_integration_settings'); do_settings_sections('word_integration_settings'); ?>
                <div class="wi-panel-section">
                    <div class="wi-panel-row">
                        <div class="wi-panel-label">Site Status:</div>
                        <div class="wi-panel-value"><span style="color:#d32f2f;font-weight:600;">NOT LIVE</span></div>
                    </div>
                    <div class="wi-panel-row">
                        <div class="wi-panel-label">Coming Soon page</div>
                        <div class="wi-panel-value">
                            <label class="wi-switch">
                                <input type="checkbox" checked disabled>
                                <span class="wi-slider"></span>
                            </label>
                            <span style="margin-left:12px;color:#1976d2;">Your website is currently displaying a "Coming Soon" page.</span>
                        </div>
                    </div>
                </div>
                <hr>
                <div class="wi-panel-section">
                    <div class="wi-panel-label" style="font-weight:600;">Features</div>
                    <div class="wi-panel-row">
                        <div class="wi-panel-label">WonderBlocks</div>
                        <div class="wi-panel-value">
                            <label class="wi-switch"><input type="checkbox" checked disabled><span class="wi-slider"></span></label>
                        </div>
                    </div>
                    <div class="wi-panel-row">
                        <div class="wi-panel-label">Help Center</div>
                        <div class="wi-panel-value">
                            <label class="wi-switch"><input type="checkbox" checked disabled><span class="wi-slider"></span></label>
                        </div>
                    </div>
                </div>
                <hr>
                <div class="wi-panel-section">
                    <div class="wi-panel-label" style="font-weight:600;">Automatic Updates</div>
                    <div class="wi-panel-row">
                        <div class="wi-panel-label">Manage All Updates</div>
                        <div class="wi-panel-value">
                            <label class="wi-switch"><input type="checkbox" checked><span class="wi-slider"></span></label>
                            <span style="margin-left:12px;color:#888;">WordPress Core, Plugins, Themes</span>
                        </div>
                    </div>
                </div>
                <hr>
                <div class="wi-panel-section">
                    <div class="wi-panel-label" style="font-weight:600;">Content Options</div>
                    <div class="wi-panel-row">
                        <div class="wi-panel-label">Number of revisions posts can save</div>
                        <div class="wi-panel-value">
                            <input type="number" name="wi_revisions" value="5" min="1" max="20" style="width:60px;">
                        </div>
                    </div>
                </div>
                <hr>
                <div class="wi-panel-section">
                    <div class="wi-panel-label" style="font-weight:600;">Word Integration Plugin Settings</div>
                    <div class="wi-panel-row">
                        <div class="wi-panel-label">Webhook URL</div>
                        <div class="wi-panel-value">
                            <input type="url" name="word_integration_webhook_url" value="<?php echo esc_attr(get_option('word_integration_webhook_url', '')); ?>" class="regular-text" placeholder="https://hook.integromat.com/your-webhook-url" />
                        </div>
                    </div>
                </div>
                <hr>
                <div class="wi-panel-section">
                    <div class="wi-panel-label" style="font-weight:600;">Test Connection</div>
                    <div class="wi-panel-row">
                        <button id="test-webhook" class="button button-secondary">Test Webhook Connection</button>
                        <div id="test-result" style="margin-left:16px;"></div>
                    </div>
                </div>
                <hr>
                <div style="margin-top:24px;">
                    <?php submit_button(); ?>
                </div>
            </form>
            <style>
            .word-integration-admin-panel { max-width: 900px; background: #fff; border-radius: 8px; box-shadow: 0 2px 12px rgba(0,0,0,0.07); padding: 32px 32px 24px 32px; }
            .wi-panel-section { margin-bottom: 24px; }
            .wi-panel-label { font-size: 16px; margin-bottom: 8px; }
            .wi-panel-row { display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px; }
            .wi-panel-row .wi-panel-label { font-size: 15px; font-weight: 400; margin-bottom: 0; }
            .wi-panel-value { display: flex; align-items: center; }
            .wi-switch { position: relative; display: inline-block; width: 44px; height: 24px; }
            .wi-switch input { opacity: 0; width: 0; height: 0; }
            .wi-slider { position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background: #e0e0e0; border-radius: 24px; transition: .4s; }
            .wi-switch input:checked + .wi-slider { background: #2566c1; }
            .wi-slider:before { position: absolute; content: ""; height: 18px; width: 18px; left: 3px; bottom: 3px; background: white; border-radius: 50%; transition: .4s; box-shadow: 0 2px 6px rgba(0,0,0,0.08); }
            .wi-switch input:checked + .wi-slider:before { transform: translateX(20px); }
            .wi-slider:after { content: ""; display: block; position: absolute; left: 0; top: 0; width: 100%; height: 100%; border-radius: 24px; }
            .wi-panel-section hr { margin: 18px 0; }
            </style>
            <script>
            jQuery(document).ready(function($) {
                $('#test-webhook').click(function(e) {
                    e.preventDefault();
                    var $button = $(this);
                    var $result = $('#test-result');
                    $button.prop('disabled', true).text('Testing...');
                    $result.html('');
                    $.ajax({
                        url: ajaxurl,
                        type: 'POST',
                        data: {
                            action: 'test_webhook_connection',
                            nonce: '<?php echo wp_create_nonce('test_webhook_nonce'); ?>'
                        },
                        success: function(response) {
                            if (response.success) {
                                $result.html('<div class="notice notice-success"><p>' + response.data.message + '</p></div>');
                            } else {
                                $result.html('<div class="notice notice-error"><p>' + response.data.message + '</p></div>');
                            }
                        },
                        error: function() {
                            $result.html('<div class="notice notice-error"><p>Connection test failed</p></div>');
                        },
                        complete: function() {
                            $button.prop('disabled', false).text('Test Webhook Connection');
                        }
                    });
                });
            });
            </script>
        </div>
        <?php
    }
    
    public function shortcode_handler($atts) {
        $atts = shortcode_atts(array(
            'style' => 'default'
        ), $atts);
        
        ob_start();
        ?>
        <div id="word-integration-interface" class="word-integration-container">
            <div class="word-integration-header">
                <h3>Word Document Manager</h3>
                <p>Manage your Word document titles using cloud processing</p>
            </div>
            <div class="word-integration-buttons">
                <input type="text" id="add-title-input" class="cool-input" placeholder="Enter any text..." style="margin-right:10px;max-width:220px;">
                <button id="add-title-btn" class="cool-button cool-button-word-light" data-action="add">
                    <span class="button-text">Add</span>
                    <span class="button-icon">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M12 5v14M5 12h14"/>
                        </svg>
                    </span>
                </button>
                <button id="remove-title-btn" class="cool-button cool-button-word-dark" data-action="remove" style="margin-right:18px;">
                    <span class="button-text">Remove</span>
                    <span class="button-icon">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M5 12h14"/>
                        </svg>
                    </span>
                </button>
                <button id="export-doc-btn" class="cool-button cool-button-word-mid" data-action="export" style="margin-right:22px;">
                    <span class="button-text">Export Document</span>
                    <span class="button-icon">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3"/>
                        </svg>
                    </span>
                </button>
            </div>
        .cool-input {
            padding: 10px 14px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 15px;
            outline: none;
            transition: border-color 0.3s;
        }
        .cool-input:focus {
            border-color: #2566c1;
            box-shadow: 0 0 0 2px rgba(37,102,193,0.12);
        }
            
            <div id="remove-section-selector" class="word-integration-section" style="display: none;">
                <h4>Remove Section:</h4>
                <select id="section-dropdown" class="regular-text">
                    <option value="Title">Title</option>
                </select>
                <button id="confirm-remove-btn" class="cool-button cool-button-word-dark cool-button-sm" style="margin-left: 10px;">
                    <span class="button-text">Remove</span>
                    <span class="button-icon">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M5 12h14"/>
                        </svg>
                    </span>
                </button>
                <button id="cancel-remove-btn" class="cool-button cool-button-ghost cool-button-sm" style="margin-left: 5px;">
                    <span class="button-text">Cancel</span>
                    <span class="button-icon">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <circle cx="12" cy="12" r="5" fill="white" />
                        </svg>
                    </span>
                </button>
            </div>
            
            <div id="word-integration-status" class="word-integration-status"></div>
            
            <div id="word-integration-result" class="word-integration-result"></div>
        </div>
        
        <style>
        .word-integration-container {
            background: #fff;
            border: 1px solid #ddd;
            border-radius: 5px;
            padding: 20px;
            margin: 20px 0;
            max-width: 600px;
        }
        
        .word-integration-header {
            margin-bottom: 20px;
            border-bottom: 1px solid #eee;
            padding-bottom: 15px;
        }
        
        .word-integration-header h3 {
            margin: 0 0 10px 0;
            color: #333;
        }
        
        .word-integration-header p {
            margin: 0;
            color: #666;
            font-style: italic;
        }
        
        .word-integration-buttons {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }
        /* Cool Animated Buttons - Word Color Palette */
        .cool-button {
            position: relative;
            display: inline-flex;
            align-items: center;
            justify-content: space-between;
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            overflow: hidden;
            transition: all 0.3s ease;
            text-decoration: none;
            min-width: 140px;
        }
        .cool-button-sm {
            padding: 8px 16px;
            font-size: 13px;
            min-width: 100px;
        }
        .cool-button .button-text {
            transition: opacity 0.5s ease;
            z-index: 2;
            position: relative;
            min-width: 90px;
        }
        .cool-button .button-icon {
            position: absolute;
            right: 8px;
            top: 50%;
            transform: translateY(-50%);
            width: 24px;
            height: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: rgba(255,255,255,0.18);
            border-radius: 6px;
            transition: all 0.5s cubic-bezier(.4,0,.2,1);
            z-index: 10;
        }
        .cool-button-sm .button-icon {
            width: 20px;
            height: 20px;
            right: 6px;
        }
        .cool-button:hover .button-text {
            opacity: 0;
        }
        .cool-button:hover .button-icon {
            width: calc(100% - 16px);
            right: 8px;
            left: auto;
            background: rgba(255,255,255,0.32);
        }
        .cool-button:active {
            transform: scale(0.95);
        }
        /* Word Color Palette Buttons */
        .cool-button-word-light {
            background: linear-gradient(90deg, #54a8ec 0%, #2566c1 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(84,168,236,0.18);
        }
        .cool-button-word-light:hover {
            box-shadow: 0 6px 20px rgba(84,168,236,0.28);
            transform: translateY(-2px);
        }
        .cool-button-word-mid {
            background: linear-gradient(90deg, #2566c1 0%, #3887d7 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(37,102,193,0.18);
        }
        .cool-button-word-mid:hover {
            box-shadow: 0 6px 20px rgba(37,102,193,0.28);
            transform: translateY(-2px);
        }
        .cool-button-word-dark {
            background: linear-gradient(90deg, #1a3e7a 0%, #2566c1 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(26,62,122,0.18);
        }
        .cool-button-word-dark:hover {
            box-shadow: 0 6px 20px rgba(26,62,122,0.28);
            transform: translateY(-2px);
        }
        /* Ghost Button */
        .cool-button-ghost {
            background: transparent;
            border: 2px solid #e0e0e0;
            color: #2566c1;
        }
        .cool-button-ghost .button-icon {
            background: rgba(37,102,193,0.05);
        }
        .cool-button-ghost:hover {
            border-color: #2566c1;
            background: rgba(37,102,193,0.02);
        }
        .cool-button-ghost:hover .button-icon {
            background: rgba(37,102,193,0.12);
        }
        /* Loading state */
        .cool-button:disabled {
            opacity: 0.7;
            cursor: not-allowed;
            transform: none !important;
        }
        .cool-button:disabled:hover {
            transform: none !important;
            box-shadow: none !important;
        }
        }
        
        .word-integration-section {
            background: #f9f9f9;
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 20px;
            margin: 15px 0;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
        }
        
        .word-integration-section h4 {
            margin: 0 0 15px 0;
            color: #333;
            font-size: 16px;
        }
        
        .word-integration-section select {
            padding: 8px 12px;
            border: 2px solid #e0e0e0;
            border-radius: 6px;
            font-size: 14px;
            transition: border-color 0.3s ease;
        }
        
        .word-integration-section select:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        
        .word-integration-status {
            margin: 15px 0;
            padding: 12px 16px;
            border-radius: 8px;
            display: none;
            font-weight: 500;
        }
        
        .word-integration-status.loading {
            background: linear-gradient(135deg, #e7f3ff 0%, #f0f8ff 100%);
            border: 1px solid #b3d9ff;
            color: #0073aa;
            display: block;
            position: relative;
        }
        
        .word-integration-status.loading::before {
            content: '';
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            width: 16px;
            height: 16px;
            border: 2px solid #0073aa;
            border-top: 2px solid transparent;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-right: 8px;
        }
        
        .word-integration-status.loading {
            padding-left: 40px;
        }
        
        @keyframes spin {
            0% { transform: translateY(-50%) rotate(0deg); }
            100% { transform: translateY(-50%) rotate(360deg); }
        }
        
        .word-integration-status.success {
            background: linear-gradient(135deg, #d4edda 0%, #e7f5e8 100%);
            border: 1px solid #c3e6cb;
            color: #155724;
            display: block;
        }
        
        .word-integration-status.error {
            background: linear-gradient(135deg, #f8d7da 0%, #fce4e6 100%);
            border: 1px solid #f5c6cb;
            color: #721c24;
            display: block;
        }
        
        .word-integration-result {
            margin: 15px 0;
        }
        
        .download-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin: 10px 0;
            padding: 12px 20px;
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
            color: white;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 600;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(79, 172, 254, 0.3);
        }
        
        .download-link:hover {
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(79, 172, 254, 0.4);
        }
        
        /* Responsive design */
        @media (max-width: 600px) {
            .word-integration-buttons {
                flex-direction: column;
                gap: 10px;
            }
            
            .cool-button {
                width: 100%;
                justify-content: center;
            }
        }
        </style>
        <?php
        
        return ob_get_clean();
    }
    
    public function handle_ajax_request() {
        // Verify nonce
        if (!wp_verify_nonce($_POST['nonce'], 'word_integration_nonce')) {
            wp_die('Security check failed');
        }
        
        $action = sanitize_text_field($_POST['integration_action']);
        $section = isset($_POST['section']) ? sanitize_text_field($_POST['section']) : '';
        
        $response = $this->send_webhook_request($action, $section);
        
        wp_send_json($response);
    }
    
    private function send_webhook_request($action, $section = '') {
        if (empty($this->webhook_url)) {
            return array(
                'success' => false,
                'message' => 'Webhook URL not configured. Please configure it in the settings.',
                'data' => null
            );
        }
        
        // Prepare request data
        $request_data = array(
            'action' => $action,
            'timestamp' => current_time('mysql'),
            'source' => 'wordpress'
        );
        switch ($action) {
            case 'add':
                // $section is the user text from JS
                $request_data['Add'] = $section;
                break;
            case 'remove':
                if (empty($section)) {
                    return array(
                        'success' => false,
                        'message' => 'Section is required for remove action',
                        'data' => null
                    );
                }
                $request_data['section'] = $section;
                break;
            case 'export':
                // No additional data needed for export
                break;
            case 'get_sections':
                // Request to get available sections
                break;
            default:
                return array(
                    'success' => false,
                    'message' => 'Invalid action specified',
                    'data' => null
                );
        }
        
    // API Key logic removed
        
        // Send HTTP request to Make.com webhook
        $response = wp_remote_post($this->webhook_url, array(
            'method' => 'POST',
            'timeout' => 30,
            'headers' => array(
                'Content-Type' => 'application/json',
                'User-Agent' => 'WordPress-WordIntegration/1.0'
            ),
            'body' => json_encode($request_data)
        ));
        
        if (is_wp_error($response)) {
            return array(
                'success' => false,
                'message' => 'Request failed: ' . $response->get_error_message(),
                'data' => null
            );
        }
        
        $response_code = wp_remote_retrieve_response_code($response);
        $response_body = wp_remote_retrieve_body($response);
        
        if ($response_code !== 200) {
            return array(
                'success' => false,
                'message' => 'Request failed with status code: ' . $response_code,
                'data' => array('response_body' => $response_body)
            );
        }
        
        $data = json_decode($response_body, true);
        
        if (json_last_error() !== JSON_ERROR_NONE) {
            return array(
                'success' => false,
                'message' => 'Invalid JSON response from webhook',
                'data' => array('response_body' => $response_body)
            );
        }
        
        return array(
            'success' => true,
            'message' => isset($data['message']) ? $data['message'] : 'Operation completed successfully',
            'data' => $data
        );
    }
}

// Initialize the plugin
new WordIntegrationMakecom();

// Add AJAX handler for webhook testing (admin only)
add_action('wp_ajax_test_webhook_connection', function() {
    if (!wp_verify_nonce($_POST['nonce'], 'test_webhook_nonce')) {
        wp_die('Security check failed');
    }
    
    $webhook_url = get_option('word_integration_webhook_url', '');
    
    if (empty($webhook_url)) {
        wp_send_json_error(array('message' => 'Webhook URL not configured'));
        return;
    }
    
    $test_data = array(
        'action' => 'test',
        'timestamp' => current_time('mysql'),
        'source' => 'wordpress_test'
    );
    
    $response = wp_remote_post($webhook_url, array(
        'method' => 'POST',
        'timeout' => 10,
        'headers' => array(
            'Content-Type' => 'application/json'
        ),
        'body' => json_encode($test_data)
    ));
    
    if (is_wp_error($response)) {
        wp_send_json_error(array('message' => 'Connection failed: ' . $response->get_error_message()));
        return;
    }
    
    $response_code = wp_remote_retrieve_response_code($response);
    
    if ($response_code === 200) {
        wp_send_json_success(array('message' => 'Webhook connection successful!'));
    } else {
        wp_send_json_error(array('message' => 'Webhook returned status code: ' . $response_code));
    }
});
?>
