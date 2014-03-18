# Adding a NillableString module because strong_parameters accepts only a specific class for scalar values
# for parameters. This is desirable for params that are valid as nil or as a string. Without this, nil param
# is not permitted.

module NillableString
end

class String
  include NillableString
end

class NilClass
  include NillableString
end