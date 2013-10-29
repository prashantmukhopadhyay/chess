class Employee
  attr_accessor :salary

  def initialize(name, title, salary, boss)
    @name, @title, @salary, @boss = name, title, salary, boss
  end

  def set_boss(boss)
    @boss = boss
  end

  def bonus(multiplier)

    @salary * multiplier
  end
end

class Manager < Employee
  def initialize(name, title, salary, boss)
    super(name, title, salary, boss)
    @employees = []
  end

  def add_employee(employee)
    @employees << employee
    employee.set_boss(self)
  end

  def bonus(multiplier)
    salary_sum = 0
    @employees.each do |employee|
      salary_sum += employee.salary * multiplier
      salary_sum += employee.bonus(multiplier) if employee.is_a?(Manager)
    end
    salary_sum
  end
end

e1 = Employee.new("bob", "dog", 134, nil)
e2 = Employee.new("2asdg", "345", 2452, nil)
m1 = Manager.new("asdf", "sdf", 3124, nil)
m1.add_employee(e1)
m1.add_employee(e2)
m2 = Manager.new("Super", "2s", 235235, nil)
m2.add_employee(m1)

p m2.bonus(1)