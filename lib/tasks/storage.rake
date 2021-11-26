namespace :storage do
  desc 'Migrate files to ActiveStorage'
  task migrate: :environment do
    def erase_line
      # https://en.wikipedia.org/wiki/ANSI_escape_code#Escape_sequences
      print "\e[1E\e[1A\e[K"
    end

    unattached_emails = RawEmail.left_joins(:file_attachment).
                                 where(active_storage_attachments: { id: nil })
    count = unattached_emails.count

    if unattached_emails.empty?
      puts 'There are no files which need to be migrated.'
      exit
    end

    unattached_emails.find_each.with_index do |e, i|
      Kernel.silence_warnings { e.data = e.data }
      erase_line
      print "Migrated raw email (#{i + 1}/#{count})"
    end

    erase_line
    puts 'Migration complete.'
  end
end
