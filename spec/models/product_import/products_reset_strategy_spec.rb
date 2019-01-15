require 'spec_helper'

describe ProductImport::ProductsResetStrategy do
  let(:products_reset) { described_class.new(excluded_items_ids) }

  describe '#reset' do
    let(:supplier_ids) { enterprise.id }
    let(:product) { create(:product) }
    let(:enterprise) { product.supplier }
    let(:variant) { product.variants.first }

    before { variant.count_on_hand = 2 }

    context 'when there are excluded_items_ids' do
      let(:excluded_items_ids) { [variant.id] }

      context 'and supplier_ids is []' do
        let(:supplier_ids) { [] }

        it 'does not reset the variant.count_on_hand' do
          products_reset.reset(supplier_ids)
          expect(variant.reload.count_on_hand).to eq(2)
        end
      end

      context 'and supplier_ids is nil' do
        let(:supplier_ids) { nil }

        it 'does not reset the variant.count_on_hand' do
          products_reset.reset(supplier_ids)
          expect(variant.reload.count_on_hand).to eq(2)
        end
      end

      context 'and supplier_ids is set' do
        it 'does not update the count_on_hand of the excluded items' do
          products_reset.reset(supplier_ids)
          expect(variant.reload.count_on_hand).to eq(2)
        end

        it 'updates the count_on_hand of the non-excluded items' do
          non_excluded_variant = create(
            :variant,
            product: variant.product
          )
          non_excluded_variant.count_on_hand = 3
          products_reset.reset(supplier_ids)
          expect(non_excluded_variant.reload.count_on_hand).to eq(0)
        end
      end
    end

    context 'when there are no excluded_items_ids' do
      let(:excluded_items_ids) { [] }

      context 'and supplier_ids is []' do
        let(:supplier_ids) { [] }

        it 'does not reset the variant.count_on_hand' do
          products_reset.reset(supplier_ids)
          expect(variant.reload.count_on_hand).to eq(2)
        end
      end

      context 'and supplier_ids is nil' do
        let(:supplier_ids) { nil }

        it 'does not reset the variant.count_on_hand' do
          products_reset.reset(supplier_ids)
          expect(variant.reload.count_on_hand).to eq(2)
        end
      end

      context 'and supplier_ids is not nil' do
        it 'sets all count_on_hand to 0' do
          updated_records_count = products_reset.reset(supplier_ids)
          expect(variant.reload.count_on_hand).to eq(0)
          expect(updated_records_count).to eq(1)
        end

        context 'and there is an unresetable variant' do
          before do
            variant.stock_items = [] # this makes variant.count_on_hand fail
          end

          it 'returns correct number of resetted variants' do
            updated_records_count = products_reset.reset(supplier_ids)
            expect(updated_records_count).to eq(0) # the variant is not updated
          end
        end
      end
    end

    context 'when excluded_items_ids is nil' do
      let(:excluded_items_ids) { nil }

      context 'and supplier_ids is []' do
        let(:supplier_ids) { [] }

        it 'does not reset the variant.count_on_hand' do
          products_reset.reset(supplier_ids)
          expect(variant.reload.count_on_hand).to eq(2)
        end
      end

      context 'and supplier_ids is nil' do
        let(:supplier_ids) { nil }
        it 'does not reset the variant.count_on_hand' do
          products_reset.reset(supplier_ids)
          expect(variant.reload.count_on_hand).to eq(2)
        end
      end

      context 'and supplier_ids is nil' do
        it 'sets all count_on_hand to 0' do
          products_reset.reset(supplier_ids)
          expect(variant.reload.count_on_hand).to eq(0)
        end
      end
    end
  end
end
