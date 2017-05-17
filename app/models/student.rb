class Student < ApplicationRecord
  validates :perm, :presence => true, :uniqueness => true
  validates :email, :presence => true, :uniqueness => true

  def self.import(file, header_map, header_row_exists)
    ext = File.extname(file.original_filename)
    spreadsheet = Roo::Spreadsheet.open(file, extension: ext)

    # get index for each param
    id_index = header_map.index("student_id")
    email_index = header_map.index("email")
    first_name_index = header_map.index("first_name")
    last_name_index = header_map.index("last_name")
    full_name_index = header_map.index("full_name")

    # start at row 1 if header row exists (via checkbox)
    ((header_row_exists ? 1 : 0 )..spreadsheet.last_row).each do |r|

      row = {}

      row["student_id"] = r[id_index]
      row["email"] = r[email_index]

      if first_name_index
        row["first_name"] = r[first_name_index]
        row["last_name"] = r[last_name_index]
      else
        name_arr = r[full_name_index].split(" ") # this seems prone to bugs because last names are weird
        row["first_name"] = name_arr[0]
        row["last_name"] = name_arr[1]
      end

      next if row.values.all?(&:nil?) # skip empty rows

      student = Student.find_by(perm: row["student_id"]) || new

      # so we need the index of each field
      # first, perm

      student.perm = row["student_id"]
      student.first_name = row["first_name"]
      student.last_name = row["last_name"]
      student.email = row["email"]
      student.save!

    end
  end

  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << %w[perm email first_name last_name github_username]

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
