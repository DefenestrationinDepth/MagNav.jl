using MagNav, Test, MAT

xyz_file = joinpath(@__DIR__,"test_data/Flt1003_sample.xyz")
xyz_h5   = joinpath(@__DIR__,"Flt1003_sample.h5")

data = xyz2h5(xyz_file,xyz_h5,:Flt1003;return_data=true)

flights = [:fields20,:fields21,:fields160,
           :Flt1001,:Flt1002,:Flt1003,:Flt1004,:Flt1005,:Flt1004_1005,
           :Flt1006,:Flt1007,:Flt1008,:Flt1009,
           :Flt1001_160Hz,:Flt1002_160Hz,:Flt2001_2017]

@testset "xyz2h5 tests" begin
    @test typeof(xyz2h5(xyz_file,xyz_h5,:Flt1003)) == Nothing
    rm(xyz_h5)
    @test typeof(xyz2h5(xyz_file,xyz_h5,:Flt1003;
                 lines=[(1003.02,50713.0,50713.2)],lines_type=:include)) == Nothing
    rm(xyz_h5)
    @test typeof(xyz2h5(xyz_file,xyz_h5,:Flt1003;
                 lines=[(1003.02,50713.0,50713.2)],lines_type=:exclude)) == Nothing
    rm(xyz_h5)
    @test_throws ErrorException xyz2h5(xyz_file,xyz_h5,:Flt1003;
                 lines=[(1003.02,50713.0,50713.2)],lines_type=:test)
    @test typeof(xyz2h5(xyz_file,xyz_h5,:Flt1003;return_data=true)) <: Matrix
    @test typeof(xyz2h5(xyz_file,xyz_h5,:Flt1001_160Hz;return_data=true)) <: Matrix
    @test typeof(xyz2h5(data,xyz_h5,:Flt1003)) == Nothing
end

xyz = get_XYZ20(xyz_h5)

@testset "h5 field tests" begin
    @test_nowarn MagNav.delete_field(xyz_h5,:lat)
    @test_nowarn MagNav.write_field(xyz_h5,:lat,xyz.traj.lat)
    @test_nowarn MagNav.overwrite_field(xyz_h5,:lat,xyz.traj.lat)
    @test_nowarn MagNav.read_field(xyz_h5,:lat)
    @test_nowarn MagNav.rename_field(xyz_h5,:lat,:lat)
    @test_nowarn MagNav.clear_fields(xyz_h5)
end

rm(xyz_h5)

@testset "xyz field tests" begin
    @test_nowarn MagNav.print_fields(xyz)
    @test_nowarn MagNav.compare_fields(xyz,xyz)
    @test MagNav.field_check(xyz,MagNav.Traj) == [:traj]
    @test MagNav.field_check(xyz,:traj)
    @test MagNav.field_check(xyz,:traj,MagNav.Traj)
end

@testset "field_extrema tests" begin
    @test MagNav.field_extrema(xyz,:line,1003.01) == (49820.0,49820.2)
    @test_throws ErrorException MagNav.field_extrema(xyz,:flight,-1)
end

@testset "xyz_fields tests" begin
    for flight in flights
        @test_nowarn xyz_fields(flight)
    end
    @test_throws ErrorException xyz_fields(:test)
end
