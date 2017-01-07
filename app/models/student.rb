class Student < ApplicationRecord
  validates :perm, :presence => true, :uniqueness => true
  validates :email, :presence => true, :uniqueness => true

  def self.import(file)
    ext = File.extname(file.original_filename)
    spreadsheet = Roo::Spreadsheet.open(file, extension: ext)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      next if row.values.all?(&:nil?)
      perm = row["Perm #"]

      student = Student.find_by(perm: perm) || new
      student.perm = perm
      student.first_name = row["Student First Middle"]
      student.last_name = row["Student Last"]
      student.email = row["Email"]
      student.save!
    end
  end

  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << ['perm', 'email', 'first_name', 'last_name', 'github_username']

      all.each do |user|
        csv << [
          user.perm,
          user.email,
          user.first_name,
          user.last_name,
          user.username
        ]
      end
    end
  end
end
