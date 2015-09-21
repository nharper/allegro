require 'io/console'
require 'csv'
require 'net/http'
require 'nokogiri'

class GroupanizerScraper
  def initialize(cookies = nil)
    @http_conn = Net::HTTP.new('sfgmc.groupanizer.com', 443)
    @http_conn.use_ssl = true

    @headers = { 'User-Agent' => 'AllegroBot/0.1' }
    @cookies = {}
    if cookies
      @cookies = cookies
    end

    login unless logged_in?
    raise 'Login failed' unless logged_in?
  end

  def inactive
    path = '/g/members?field_full_name_value=&field_voice_part_tid=All&rid%5B%5D=256320132&field_titles_tid=All&field_skills_tid=All'
    return members(path)
  end

  def active
    path = '/g/members?field_full_name_value=&field_voice_part_tid=All&rid%5B%5D=4190371&field_titles_tid=All&field_skills_tid=All'
    return members(path)
  end

  def alumni
    path = '/g/members?field_full_name_value=&field_voice_part_tid=All&rid%5B%5D=8899772&field_titles_tid=All&field_skills_tid=All'
    return members(path)
  end

  def members(path)
    has_next = true
    members = {}

    members_html = nil
    while has_next
      puts "Fetching path: #{path}"
      members_resp = @http_conn.get(path, @headers)
      update_cookies(members_resp.get_fields('Set-Cookie'))

      members_html = Nokogiri::HTML(members_resp.body)
      members_html.css('table tr').each do |row|
        entry = {}
        entry['img'] = row.at_css('img')['src']
        name_link = row.at_css('.views-field-field-full-name a')
        entry['name'] = name_link.content.strip.split(',').map{|n| n.strip}.reverse.join(' ')
        entry['foreign_key'] = name_link['href']
        members[entry['name']] = entry
      end
      has_next = false
      next_link = members_html.at_css('.pager-next a')
      if next_link
        path = next_link['href']
        has_next = true
      end
    end
    csv_resp = @http_conn.get(
        members_html.at_css('#g-members-export')['href'],
        @headers)
    csv = CSV::parse(csv_resp.body)
    headers = csv.shift
    first_name_index = headers.index("First name")
    last_name_index = headers.index("Last name")
    chorus_number_index = headers.index("Member ID")
    if !first_name_index || !last_name_index || !chorus_number_index
      raise "Unable to find needed columns: Headers are #{headers}"
    end
    csv.each do |line|
      name = line[first_name_index].strip + ' ' + line[last_name_index].strip
      entry = members[name]
      if !entry
        raise "Name found in csv that wasn't scraped: #{name}"
      end
      entry['chorus_number'] = line[chorus_number_index]
    end
    return members
  end

  # XXX musetta
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
    # try requesting the homepage - 302 response redirecting to login page means we need to log in; 200 means we're good, and anything else is unexpected
    homepage_resp= @http_conn.get('/', @headers)
    update_cookies(homepage_resp.get_fields('Set-Cookie'))
    if homepage_resp.code == '302' && homepage_resp['Location'] == 'https://sfgmc.groupanizer.com/user/login?destination=g/dashboard'
      return false
    elsif homepage_resp.code != '200'
      raise "Unexpected code: #{homepage_resp.code}"
    end
    return true
  end

  def login
    response_data = {}

    login_form_resp = @http_conn.get('/user/login?destination=g/dashboard', @headers)
    update_cookies(login_form_resp.get_fields('Set-Cookie'))
    
    # parse form input tags to prepare data to send back
    login_form_html = Nokogiri::HTML(login_form_resp.body)
    form = login_form_html.at_css("#user-login")
    form.css("input").each do |input|
      if input['value']
        response_data[input['name']] = input['value']
      end
    end

    response_data['name'] = req_console('Enter login: ')
    response_data['pass'] = req_console('Enter password: ', false)

    form_headers = @headers.clone
    form_headers['Content-Type'] = 'application/x-www-form-urlencoded'

    login_resp = @http_conn.post('/user/login?destination=g/dashboard', response_data.to_query, form_headers)
    update_cookies(login_resp.get_fields('Set-Cookie'))
    raise "Unexpected code: #{login_resp.code}" unless login_resp.code == '302'
    return login_resp['Location'] == 'https://sfgmc.groupanizer.com/g/dashboard'
  end

  # XXX musetta
  def req_console(prompt, tty_echo=true)
    restore_echo = STDIN.echo?
    STDIN.echo = false unless tty_echo
    puts prompt
    retval = STDIN.gets.strip
    STDIN.echo = restore_echo
    puts "" unless tty_echo # simulate feedback that user pressed return
    return retval
  end

  # XXX musetta
  def update_cookies(cookies)
    return unless cookies
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