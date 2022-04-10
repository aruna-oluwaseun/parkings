unless Rails.env.test?
  Grover.configure do |config|
    config.options = {
      format: 'A4',
      wait_until: 'networkidle0',
      launch_args: ['--no-sandbox'],
      prefer_css_page_size: true,
      print_background: true
    }
  end
end
