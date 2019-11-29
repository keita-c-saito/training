namespace :maintenance do
  desc 'This task manage maintenance.'

  task on: [:environment] do
    config = Config.find_by(name: 'maintenance')
    puts '既にメンテナンスモードです' if config.on?
    next unless config.off?
    config.update(enabled: 'on')
    puts 'メンテナンスモードになりました'
  end

  task off: [:environment] do
    config = Config.find_by(name: 'maintenance')
    puts 'メンテナンスモードではないです' if config.off?
    next unless config.on?
    config.update(enabled: 'off')
    puts 'メンテナンスモードを解除しました'
  end
end
