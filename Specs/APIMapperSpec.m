#import "SpecHelper.h"

#import "APIMapper.h"

#import "Product.h"

@interface APITestMappingProvider : NSObject <APIMappingProvider>
@end

@implementation APITestMappingProvider
- (NSDictionary *)mappingsForResource:(Class)resource;
{
    return @{@"productName": @"name"};
}
@end

SpecBegin(APIMapper)

__block APIMapper *_mapper;
__block NSDictionary *_values;

describe(@"APIMapper", ^{

    before(^{
        _mapper = [[APIMapper alloc] init];

        _values = @{
             @"name": @"Karma",
             @"price": @(79)
        };
    });

    it(@"maps value to an instance using a mapping", ^{
        Product *product = [_mapper mapValues:_values toResource:[Product class]];
        expect(product.name).to.equal(@"Karma");
        expect(product.price).to.equal(79);
    });

    it(@"can map collections", ^{
        NSArray *products = [_mapper mapValues:@[_values] toResource:[Product class]];
        Product *product = products[0];
        expect(product.name).to.equal(@"Karma");
        expect(product.price).to.equal(79);
    });

    it(@"maps snake case to camelCase", ^{
        _values = @{
            @"name": @"Karma",
            @"price": @(79),
            @"in_stock": @(true)
        };
        Product *product = [_mapper mapValues:_values toResource:[Product class]];
        expect(product.inStock).to.beTruthy();
    });

    it(@"can be configured with different mappings", ^{
        _values = @{
            @"productName": @"Karma"
        };
        _mapper = [[APIMapper alloc] initWithMappingProvider:[[APITestMappingProvider alloc] init]];
        Product *product = [_mapper mapValues:_values toResource:[Product class]];
        expect(product.name).to.equal(@"Karma");
    });
});

SpecEnd