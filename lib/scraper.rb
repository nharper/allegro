require 'io/console'
require 'net/http'
require 'nokogiri'

class MusettaScraper
  def initialize(cookies = nil)
    @http_conn = Net::HTTP.new('sfgmc.musetta.org', 443)
    @http_conn.use_ssl = true

    @headers = { 'User-Agent' => 'musetta-scraper/0.1' }
    @cookies = {}
    if cookies
      @cookies = cookies
    end

    login unless logged_in?
    raise 'Login failed' unless logged_in?
  end

  def roster
    roster_resp = @http_conn.get('/rosters', @headers)
    update_cookies(roster_resp.get_fields('Set-Cookie'))

    roster_html = Nokogiri::HTML(roster_resp.body)
    roster = []
    roster_html.css('#roster .entry').each do |entry_dom|
      data = entry_dom.at_css('.data')
      entry = {}
      entry['section'] = data.at_css('.section').content
      entry['cn'] = data.at_css('.cn').content.to_i
      entry['name'] = data.at_css('.name').content.strip
      data.css('.item').each do |item|
        children = item.css('span')
        if children.size == 2 && children[0]['class'] == 'title'
          entry[children[0].text.split(':')[0]] = children[1].text.strip
        end
      end
      img = entry_dom.at_css('img.roster_photo')
      entry['img'] = img['src']

      roster.push(entry)
    end

    return roster
  end

  def scrape_path(path)
    path_resp = @http_conn.get(path, @headers)

    return path_resp.body
  end

  private

  def logged_in?
    # try requesting the homepage - 302 response to /logins/new means we need to log in; 200 means we're good, and anything else is unexpected
    homepage_resp= @http_conn.get('/', @headers)
    update_cookies(homepage_resp.get_fields('Set-Cookie'))
    if homepage_resp.code == '302' && homepage_resp['Location'] == 'https://sfgmc.musetta.org/logins/new'
      return false
    elsif homepage_resp.code != '200'
      raise "Unexpected code: #{homepage_resp.code}"
    end
    return true
  end

  def login
    response_data = {}

    login_form_resp = @http_conn.get('/logins/new', @headers)
    update_cookies(login_form_resp.get_fields('Set-Cookie'))
    
    # parse form input tags to prepare data to send back
    login_form_html = Nokogiri::HTML(login_form_resp.body)
    form = login_form_html.at_css("form")
    form.css("input").each do |input|
      if input['value']
        response_data[input['name']] = input['value']
      end
    end

    response_data['login[login]'] = req_console('Enter login: ')
    response_data['login[password]'] = req_console('Enter password: ', false)

    form_headers = @headers.clone
    form_headers['Content-Type'] = 'application/x-www-form-urlencoded'

    login_resp = @http_conn.post('/logins', response_data.to_query, form_headers)
    update_cookies(login_resp.get_fields('Set-Cookie'))
    raise "Unexpected code: #{login_resp.code}" unless login_resp.code == '302'
    return login_resp['Location'] == 'https://sfgmc.musetta.org/'
  end

  def req_console(prompt, tty_echo=true)
    restore_echo = STDIN.echo?
    STDIN.echo = false unless tty_echo
    puts prompt
    retval = STDIN.gets.strip
    STDIN.echo = restore_echo
    puts "" unless tty_echo # simulate feedback that user pressed return
    return retval
  end

  def update_cookies(cookies)
    cookies.each do |cookie|
      cookie = cookie.split(';')[0]
      name, value = cookie.split('=')
      @cookies[name] = value
    end
    cookies = []
    @cookies.each do |name, value|
      cookies.push("#{name}=#{value}")
    end
    @headers['Cookie'] = cookies.join('; ')
  end

end
