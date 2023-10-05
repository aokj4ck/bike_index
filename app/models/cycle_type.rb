class CycleType
  include Enumable
  include AutocompleteHashable

  SLUGS = {
    bike: 0,
    tandem: 1,
    unicycle: 2,
    tricycle: 3,
    stroller: 4,
    recumbent: 5,
    trailer: 6,
    wheelchair: 7,
    cargo: 8,
    "tall-bike": 9,
    "penny-farthing": 10,
    "cargo-rear": 11,
    "cargo-trike": 12,
    "cargo-trike-rear": 13,
    "trail-behind": 14,
    "pedi-cab": 15,
    "e-scooter": 16,
    "personal-mobility": 18,
    "non-e-scooter": 19,
    "non-e-skateboard": 20
  }.freeze

  NAMES = {
    bike: "Bike",
    tandem: "Tandem",
    unicycle: "Unicycle",
    tricycle: "Tricycle",
    stroller: "Stroller",
    recumbent: "Recumbent",
    trailer: "Bike Trailer",
    wheelchair: "Wheelchair",
    cargo: "Cargo Bike (front storage)",
    "tall-bike": "Tall Bike",
    "penny-farthing": "Penny Farthing",
    "cargo-rear": "Cargo Bike (rear storage)",
    "cargo-trike": "Cargo Tricycle (front storage)",
    "cargo-trike-rear": "Cargo Tricycle (rear storage)",
    "trail-behind": "Trail behind (half bike)",
    "pedi-cab": "Pedi Cab (rickshaw)",
    "e-scooter": "E-Scooter",
    "personal-mobility": "E-Skateboard (E-Unicycle, Personal mobility device, etc)",
    "non-e-scooter": "Scooter (Not electric)",
    "non-e-skateboard": "Skateboard (Not electric)"
  }.freeze

  MODEST_PRIORITY = %i[tricycle tandem recumbent personal-mobility].freeze

  def self.searchable_names
    slugs
  end

  def initialize(slug)
    @slug = slug&.to_sym
    @id = SLUGS[@slug]
  end

  attr_reader :slug, :id

  def priority
    if slug == :bike
      950
    elsif slug == :"cargo-rear"
      940
    elsif slug == :"e-scooter"
      930
    elsif MODEST_PRIORITY.include?(slug)
      920
    else
      900
    end
  end

  def search_id
    "v_#{id}"
  end

  def autocomplete_hash
    {
      id: id,
      text: name,
      category: "cycle_type",
      priority: priority,
      data: {
        priority: priority,
        slug: slug,
        search_id: search_id
      }
    }
  end
end
